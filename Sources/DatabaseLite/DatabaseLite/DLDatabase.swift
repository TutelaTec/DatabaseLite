//
//  DLDatabase.swift
//  DLDatabase
//
//  Created by Mark Morrill on 2021-08-03.
//

import Foundation
import SQLite3

class DLDatabase {
    
    let sqlite: OpaquePointer
    
    
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
