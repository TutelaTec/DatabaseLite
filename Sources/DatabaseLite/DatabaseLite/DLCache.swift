//
//  File.swift
//  
//
//  Created by Mark Morrill on 2022-02-25.
//

import Foundation

public class DLCache {
    typealias Table = [DLTablable.RowId:DLTablable]
    typealias Cache = [String:Table]
    var cache = Cache()

    private func cached<T:DLTablable>(forTable table: T.Type, whereRowId rowId:DLTablable.RowId) throws -> T? {
        let key = table.tableName
        if let tab = cache[key] {
            return tab[rowId] as? T
        }
        return nil
    }
    
    private func save(_ it:DLTablable) throws {
        let key = type(of: it).tableName
        var table: Table = cache[key] ?? Table()
        table[it.rowId] = it
        cache[key] = table
    }
    
    func fetch<T:DLTablable>(forTable table: T.Type, whereRowId rowId:DLTablable.RowId, fromDatabase db:DLDatabase) throws -> T {
        if let it = try cached(forTable: T.self, whereRowId: rowId) {
            return it
        }
        if let it = try db.select(tableFor: T.self, whereRowId: rowId) {
            try self.save(it)
            return it
        }
        throw DLDatabaseError("\(rowId) not found for \(table)")
    }
}
