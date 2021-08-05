//
//  DLDatabase.swift
//  DLDatabase
//
//  Created by Mark Morrill on 2021-08-03.
//

import Foundation
import SQLite3

class DLDatabase {
    
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
    
    
    init( _ sql: OpaquePointer ) {
        sqlite = sql
    }
    
    init( atPath path: String ) throws {
        var db:OpaquePointer?
        guard SQLITE_OK == sqlite3_open_v2(path, &db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | SQLITE_OPEN_FULLMUTEX, nil), let db = db else {
            throw DLDatabaseError("Unable to create database at \(path)")
        }
        sqlite = db
    }
    
    func close() {
        sqlite = nil
    }
    deinit {
        close()
    }
    
    func checkResult(_ result: Int32) throws {
        try checkResult(Int(result))
    }

    func checkResult(_ result: Int) throws {
        if result != Int(SQLITE_OK) {
            throw DLSqliteError(result, self.errorMessage)
        }
    }

    
    func create<T:Decodable & DLTablable>(tableFor type: T.Type) throws {
        
        let named = type.tableName
        let decoder = DLColumnNamesDecoder()
        var isPrimary = true
        let columns = try decoder.decode(type).map({ col -> String in
            let cmd = try col.command(isPrimary: isPrimary)
            isPrimary = false
            return cmd
        })
        print( "CREATE TABLE IF NOT EXISTS \(named) ( \(columns.joined(separator: ", ")) )" )

    }
    
    func prepare(statement stmt: String) throws -> DLStatement {
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
        return DLStatement(db, stmt: stmtPtr)
    }
    
    func forEachRow(statement: String, doBindings: (DLStatement) throws -> (), handleRow: (DLStatement, Int) throws -> ()) throws {
        let stmt = try prepare(statement: statement)
        defer { stmt.finalize() }

        try doBindings(stmt)

        try forEachRowBody(statement: stmt, handleRow: handleRow)
    }

    func forEachRowBody(statement: DLStatement, handleRow: (DLStatement, Int) throws -> ()) throws {
        var r = stat.step()
        guard r == SQLITE_ROW || r == SQLITE_DONE else {
            try checkResult(r)
            return
        }
        
        var rowNum = 1
        while r == SQLITE_ROW {
            try handleRow(stat, rowNum)
            rowNum += 1
            r = stat.step()
        }
    }

}



extension DLColumn {

    func command(isPrimary:Bool = false) throws -> String {
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
