//
//  DLDatabase.swift
//  DLDatabase
//
//  Created by Mark Morrill on 2021-08-03.
//

import Foundation
import SQLite3



public class DLDatabase {
    
    var sqlite: OpaquePointer? {
        didSet {
            if let old = oldValue {
                sqlite3_close(old)
            }
        }
    }
    
    var errorMessage: String {
        return String(validatingUTF8: sqlite3_errmsg(self.sqlite)) ?? "-- not available --"
    }
    
    let cache = DLCache()
    
    public init( _ sql: OpaquePointer ) {
        sqlite = sql
    }
    
    public static let ReadWriteCreate = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE
    public static let ReadOnly = SQLITE_OPEN_READONLY
    
    public init( atPath path: String, flags:Int32 = ReadWriteCreate ) throws {
        var db:OpaquePointer?
        guard SQLITE_OK == sqlite3_open_v2(path, &db, flags | SQLITE_OPEN_FULLMUTEX, nil), let db = db else {
            throw DLDatabaseError("Unable to create database at \(path)")
        }
        sqlite = db
    }
    
    public func close() {
        sqlite = nil
    }
    deinit {
        close()
    }
    
    public func checkResult(_ result: Int32) throws {
        try checkResult(Int(result))
    }

    public func checkResult(_ result: Int) throws {
        if result != Int(SQLITE_OK) {
            throw DLSqliteError(result, self.errorMessage)
        }
    }

    public func prepare(statement stmt: String) throws -> DLStatement {
        guard let db = self.sqlite else {
            throw DLDatabaseError("missing sqlite database")
        }
        let count = Int32(stmt.utf8.count)
        guard count > 0 else {
            throw DLDatabaseError("statement is empty")
        }
        var stmtPtr = OpaquePointer(bitPattern: 0)
        let res = sqlite3_prepare_v2(db, stmt, count, &stmtPtr, nil)
        try checkResult(res)
        guard let s = stmtPtr else {
            throw DLDatabaseError("statement pointer is nil")
        }
        return DLStatement(db, stmt: s)
    }
    

    public func create<T:DLTablable>(tableFor type: T.Type) throws {
        let named = type.tableName
        let decoder = DLColumnNamesDecoder()
        var isPrimary = true
        let columns = try decoder.decode(type).map({ col -> String in
            let cmd = try col.command(isPrimary: isPrimary)
            isPrimary = false
            return cmd
        })
        guard !columns.isEmpty else { throw DLDatabaseError("Table \(named) is missing columns") }
        let query = "CREATE TABLE IF NOT EXISTS \(named) ( \(columns.joined(separator: ", ")) )"

        try execute(statement: query)
    }
    
    public func select<T:DLTablable>(tableFor type: T.Type, whereRowId rowId:DLTablable.RowId) throws -> T? {
        guard rowId != .invalid else { throw DLDatabaseError("Invalid RowId") }
        
        let named = type.tableName
        let columnNamesDecoder = DLColumnNamesDecoder()
        let columns = try columnNamesDecoder.decode(type)
        guard !columns.isEmpty, let primary = columns.first else { throw DLDatabaseError("Table \(named) is missing columns") }
        
        let selected = columns.map { column in
            column.name
        }

        let query = "select \(selected.joined(separator: ", ")) from \(named) where \(primary.name) = ?"
                
        var rows = [T]()
        let decoder = DLTableDecoder()
        
        try forEachRow(statement: query) { statement in
            try statement.bind(position: 1, rowId)
        } handleRow: { statement, _ in
            rows.append(try decoder.decode(type, from:statement))
        }
        
        return rows.first
    }
    
    
    public func select<T:DLTablable>(tableFor type: T.Type, where clauses:[DLClause]) throws -> [T] {
        guard !clauses.isEmpty else {
            return try select(tableFor: type)
        }
        
        let named = type.tableName
        let columnNamesDecoder = DLColumnNamesDecoder()
        let columns = try columnNamesDecoder.decode(type)
        guard !columns.isEmpty else { throw DLDatabaseError("Table \(named) is missing columns") }
        
        let selected = columns.map { column in
            column.name
        }
        
        let query = "select \(selected.joined(separator: ", ")) from \(named) where " + clauses.reduce("", { partialResult, clause in
            return partialResult + clause.conjunction.rawValue + " " + clause.column
        })

        var rows = [T]()
        let decoder = DLTableDecoder()
        
        try forEachRow(statement: query) { statement in
            for position in 1 ... clauses.count {
                let clause = clauses[position - 1]
                try clause.bind(statement, at:position)
            }
        } handleRow: { statement, _ in
            rows.append(try decoder.decode(type, from:statement))
        }
        
        return rows
    }
    
    public enum Order: String {
        case asc
        case desc
    }
    public func select<T:DLTablable>(rowIdsForTable type: T.Type, order:Order = .asc, offset:Int? = nil, limit:Int? = nil) throws -> [DLTablable.RowId] {
        let named = type.tableName
        let columnNamesDecoder = DLColumnNamesDecoder()
        let columns = try columnNamesDecoder.decode(type)
        guard !columns.isEmpty, let primary = columns.first else { throw DLDatabaseError("Table \(named) is missing columns") }

        var query = "select \(primary.name) from \(named) order by \(primary.name) \(order.rawValue) "
        if let offset = offset {
            query += "offset \(offset) "
        }
        if let limit = limit {
            query += "limit \(limit) "
        }
        
        var rows = [DLTablable.RowId]()
        try forEachRow(statement: query, handleRow: { statement, _ in
            let row = DLTablable.RowId(statement.columnInt64(position: 0))
            rows.append(row)
        })
        
        return rows
    }
    
    public func select<T:DLTablable>(lastRowIdForTable type: T.Type) throws -> DLTablable.RowId? {
        return try select(rowIdsForTable: type, order: .desc, limit: 1).first
    }
    
    public func select<T:DLTablable>(tableFor type: T.Type) throws -> [T] {
        let named = type.tableName
        let columnNamesDecoder = DLColumnNamesDecoder()
        let columns = try columnNamesDecoder.decode(type)
        guard !columns.isEmpty else { throw DLDatabaseError("Table \(named) is missing columns") }
        
        let selected = columns.map { column in
            column.name
        }
        
        let query = "select \(selected.joined(separator: ", ")) from \(named)"
                
        var rows = [T]()
        let decoder = DLTableDecoder()
        
        
        try forEachRow(statement: query) { statement in
            // do nothing
        } handleRow: { statement, _ in
            rows.append(try decoder.decode(type, from:statement))
        }
        
        return rows
    }
        
    /// call this when you expect to find the object in the database.
    public func fetch<T:DLTablable>(forTable table: T.Type, whereRowId rowId:DLTablable.RowId) throws -> T {
        return try cache.fetch(forTable: table, whereRowId: rowId, fromDatabase: self)
    }

    // insert a record that
    @discardableResult 
    public func insert<T:DLTablable>(_ record: inout T) throws -> DLTablable.RowId {
        let named = type(of: record).tableName
        
        let encoder = DLBindingEncoder()
        var bindings = try encoder.encode(record)
        // the first binding is the primary key. remove it
        bindings.removeFirst()

        // let's not have tables with nothing but rowid, okay
        guard !bindings.isEmpty else {
            throw DLDatabaseError("Table \(named) has no columns")
        }
        
        let columns = bindings.map { binding in
            binding.column
        }
        let marker = bindings.map { _ in
            "?"
        }

        let query = "insert into \(named) (\(columns.joined(separator: ","))) values (\(marker.joined(separator: ",")))"

        
        try execute(statement: query) { statement in
            let count = bindings.count
            for i in 1 ... count {
                let binding = bindings[i-1]
                try binding.bind(with: statement, at: i)
            }
        }
        
        let rowId = lastInsertRowId()
        record.rowId = rowId
        return rowId
    }
    
    public func lastInsertRowId() -> DLTablable.RowId {
        return sqlite3_last_insert_rowid(self.sqlite)
    }
    
    public func execute(statement: String) throws {
        try forEachRow(statement: statement, doBindings: { _ in
            // nothing
        }, handleRow: { _, _ in
            // nothing
        })
    }

    public typealias Binder = (DLStatement) throws -> Void
    public typealias RowHandler = (DLStatement, Int) throws -> Void
    
    public func execute(statement: String, doBindings: Binder) throws {
        try forEachRow(statement: statement, doBindings: doBindings) {
            _, _ in
            // nothing to be done
        }
    }

    public func execute(statement: String, count: Int, doBindings: (DLStatement, Int) throws -> ()) throws {
        let stat = try prepare(statement: statement)
        defer { stat.finalize() }

        for idx in 1...count {
            try doBindings(stat, idx)
            try forEachRowBody(statement: stat) { _, _ in
                // nothing to be done
            }
            let _ = try stat.reset()
        }
    }

    
    public func execute(WithTransaction closure: () throws -> ()) throws {
        try execute(statement: "BEGIN")
        do {
            try closure()
            try execute(statement: "COMMIT")
        } catch let e {
            try execute(statement: "ROLLBACK")
            throw e
        }
    }
    
    public func forEachRow(statement: String, handleRow: RowHandler) throws {
        let stmt = try prepare(statement: statement)
        defer { stmt.finalize() }

        try forEachRowBody(statement: stmt, handleRow: handleRow)
    }

    public func forEachRow(statement: String, doBindings: Binder, handleRow: RowHandler) throws {
        let stmt = try prepare(statement: statement)
        defer { stmt.finalize() }

        try doBindings(stmt)

        try forEachRowBody(statement: stmt, handleRow: handleRow)
    }

    public func forEachRowBody(statement: DLStatement, handleRow: RowHandler) throws {
        var r = statement.step()
        guard r == SQLITE_ROW || r == SQLITE_DONE else {
            try checkResult(r)
            return
        }
        
        var rowNum = 1
        while r == SQLITE_ROW {
            try handleRow(statement, rowNum)
            rowNum += 1
            r = statement.step()
        }
    }

}



extension DLColumn {

    public func command(isPrimary:Bool = false) throws -> String {
        guard !(isOptional && isPrimary) else {
            throw DLDatabaseError("Primary can't be optional")
        }
        var command = [String]()
        
        command.append(name)
                
        switch type {
        case is Int.Type, is Int32.Type, is Int64.Type, is UInt.Type, is UInt32.Type, is UInt64.Type:
            
            command.append( "INTEGER" )
            if isPrimary {
                command.append("PRIMARY KEY AUTOINCREMENT")
            }
            
        case is Bool.Type, is Int8.Type, is Int16.Type, is UInt8.Type, is UInt16.Type:
            if isPrimary {
                throw DLDatabaseError("\(type) is not supported as a primary index")
            }
            command.append( "INTEGER" )

        case is Float.Type, is Double.Type:
            if isPrimary {
                throw DLDatabaseError("\(type) is not supported as a primary index")
            }
            command.append( "DOUBLE" )
            
        case is String.Type:
            command.append( "TEXT" )
            if isPrimary {
                command.append("PRIMARY KEY")
            }
            
        default:
            throw DLDatabaseError("Unknown data type \(type)")
        }
        
        if !isOptional {
            command.append("NOT NULL")
        }
        
        return command.joined(separator: " ")
    }
}
