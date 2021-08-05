//
//  DLStatement.swift
//  DLStatement
//
//  Created by Mark Morrill on 2021-08-04.
//

import Foundation
import SQLite3

class DLStatement {
    typealias sqlite_destructor = @convention(c) (UnsafeMutableRawPointer?) -> Void

    let sqlite: OpaquePointer
    var statement: OpaquePointer? {
        didSet {
            if let old = oldValue {
                sqlite3_finalize(old)
            }
        }
    }
    var errorMessage: String {
        return String(validatingUTF8: sqlite3_errmsg(self.sqlite)) ?? "-- not available --"
    }

    init(_ db:OpaquePointer, stmt:OpaquePointer) {
        sqlite = db
        statement = stmt
    }
    
    deinit {
        finalize()
    }
    
    func close() {
        finalize()
    }
    
    func finalize() {
        self.statement = nil
    }
    
    func checkResult(_ result: Int32) throws {
        try checkResult(Int(result))
    }

    func checkResult(_ result: Int) throws {
        if result != Int(SQLITE_OK) {
            throw DLSqliteError(result, self.errorMessage)
        }
    }
    
    func step() -> Int32 {
        guard let statement = statement else {
            return SQLITE_MISUSE
        }
        return sqlite3_step(statement)
    }
    
    func sanity() throws {
        if nil == statement {
            throw DLDatabaseError("statement is nil")
        }
    }
    
    func reset() throws -> Int {
        try sanity()
        let result = sqlite3_reset(statement)
        try checkResult(result)
        return Int(result)
    }
    
    func bind(parameterIndexFor name: String) throws -> Int {
        let index = sqlite3_bind_parameter_index(statement, name)
        guard index != 0 else {
            throw DLSqliteError(Int(SQLITE_MISUSE), "\(name) was not found.")
        }
        return Int(index)
    }

    //MARK: - by position
    // primary bindings
    func bind(position: Int, _ i: Int64) throws {
        try sanity()
        try checkResult(sqlite3_bind_int64(statement, Int32(position), i))
    }
    func bind(position: Int, _ i: Int32) throws {
        try sanity()
        try checkResult(sqlite3_bind_int(statement, Int32(position), i))
    }
    func bind(position: Int, _ d: Double) throws {
        try sanity()
        try checkResult(sqlite3_bind_double(statement, Int32(position), d))
    }
    func bind(position: Int, _ s: String) throws {
        try sanity()
        try checkResult(sqlite3_bind_text(statement, Int32(position), s, Int32(s.utf8.count), unsafeBitCast(OpaquePointer(bitPattern: -1), to: sqlite_destructor.self)))
    }
    func bindNull(position: Int) throws {
        try sanity()
        try checkResult(sqlite3_bind_null(statement, Int32(position)))
    }

    
    // extended bindings
    func bind(position: Int, _ d:Float) throws {
        try bind(position: position, Double(d))
    }
    func bind(position: Int, _ i: Int) throws {
        try bind(position: position, Int64(i))
    }
    func bind(position: Int, _ i: Int8) throws {
        try bind(position: position, Int32(i))
    }
    func bind(position: Int, _ i: Int16) throws {
        try bind(position: position, Int32(i))
    }
    func bind(position: Int, _ b: Bool) throws {
        try bind(position: position, Int32(b ? 1 : 0))
    }
    func bind(position: Int, _ i: UInt) throws {
        try bind(position: position, Int64(i))
    }
    func bind(position: Int, _ i: UInt8) throws {
        try bind(position: position, Int32(i))
    }
    func bind(position: Int, _ i: UInt16) throws {
        try bind(position: position, Int32(i))
    }


    
    //MARK: - by name
    // primary bindings
    func bind(name: String, _ i: Int64) throws {
        try bind(position: bind(parameterIndexFor: name), i)
    }
    func bind(name: String, _ i: Int32) throws {
        try bind(position: bind(parameterIndexFor: name), i)
    }
    func bind(name: String, _ d: Double) throws {
        try bind(position: bind(parameterIndexFor: name), d)
    }
    func bind(name: String, _ s: String) throws {
        try bind(position: bind(parameterIndexFor: name), s)
    }
    func bindNull(name: String) throws {
        try bindNull(position: bind(parameterIndexFor: name))
    }

    // extended bindings
    func bind(name: String, _ d:Float) throws {
        try bind(position: bind(parameterIndexFor: name), d)
    }
    func bind(name: String, _ i: Int) throws {
        try bind(position: bind(parameterIndexFor: name), i)
    }
    func bind(name: String, _ i: Int8) throws {
        try bind(position: bind(parameterIndexFor: name), i)
    }
    func bind(name: String, _ i: Int16) throws {
        try bind(position: bind(parameterIndexFor: name), i)
    }
    func bind(name: String, _ b: Bool) throws {
        try bind(position: bind(parameterIndexFor: name), b)
    }
    func bind(name: String, _ i: UInt) throws {
        try bind(position: bind(parameterIndexFor: name), i)
    }
    func bind(name: String, _ i: UInt8) throws {
        try bind(position: bind(parameterIndexFor: name), i)
    }
    func bind(name: String, _ i: UInt16) throws {
        try bind(position: bind(parameterIndexFor: name), i)
    }

    // MARK: - Columns
    func columnCount() -> Int {
        return Int( sqlite3_column_count(self.statement))
    }
    
    func columnName(position: Int) throws -> String {
        guard let name = String(validatingUTF8: sqlite3_column_name(statement, Int32(position))) else {
            throw DLDatabaseError(self.errorMessage)
        }
        return name
    }
    
    func columnDeclType(position: Int) throws -> String {
        if let decl = String(validatingUTF8: sqlite3_column_decltype(statement, Int32(position))) else {
            throw DLDatabaseError(self.errorMessage)
        }
        return decl
    }
    
    func columnDouble(position: Int) -> Double {
        return sqlite3_column_double(statement, Int32(position))
    }
    func columnInt32(position: Int) -> Int32 {
        return sqlite3_column_int(statement, Int32(position))
    }
    func columnInt64(position: Int) -> Int64 {
        return sqlite3_column_int64(statement, Int32(position))
    }
    public func columnText(position: Int) -> String {
        if let res = sqlite3_column_text(statement, Int32(position)) {
            return res.withMemoryRebound(to: Int8.self, capacity: 0) {
                String(validatingUTF8: $0) ?? ""
            }
        }
        return ""
    }


    func columnFloat(position: Int) -> Float {
        return Float(columnDouble(position: position))
    }
    func columnInt(position: Int) -> Int {
        return Int(columnInt64(position: position))
    }
    func columnUInt(position: Int) -> UInt {
        return UInt(columnInt(position: position))
    }
    func columnUInt32(position: Int) -> UInt32 {
        return UInt32(columnInt32(position: position))
    }
    func columnUInt64(position: Int) -> UInt64 {
        return UInt64(columnInt64(position: position))
    }
    func columnInt8(position: Int) -> Int8 {
        return Int8(columnInt32(position: position))
    }
    func columnUInt8(position: Int8) -> UInt8 {
        return UInt8(columnInt32(position: position))
    }
    func columnInt16(position: Int) -> Int16 {
        return Int16(columnInt32(position: position))
    }
    func columnUInt16(position: Int) -> UInt16 {
        return UInt16(columnInt32(position: position))
    }
    func columnBool(position: Int) -> Bool {
        return 0 == columnInt32(position: position) ? false : true
    }


    func columnType(position: Int) -> Int32 {
        return sqlite3_column_type(statement, Int32(position))
    }

    func isInteger(position: Int) -> Bool {
        return SQLITE_INTEGER == columnType(position: position)
    }
    func isDouble(position: Int) -> Bool {
        return SQLITE_FLOAT == columnType(position: position)
    }
    func isText(position: Int) -> Bool {
        return SQLITE_TEXT == columnType(position: position)
    }
    func isNull(position: Int) -> Bool {
        return SQLITE_NULL == columnType(position: position)
    }
    // we are not handling blogs yet but here is a method anyhow
    func isBlob(position: Int) -> Bool {
        return SQLITE_BLOB == columnType(position: position)
    }

}
