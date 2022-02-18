//
//  DLTablable.swift
//  DLTablable
//
//  Created by Mark Morrill on 2021-08-03.
//

import Foundation

public protocol DLTablable: Codable {
    typealias RowId = Int64
    static var tableName: String {get}
    
    /// table's first row must be the rowId and Int. This is the primary key. Keep in mind that such a primary key should not be used in a web interface
    /// this column never gets updated, nor inserted
    var rowId: RowId { get set }
    
    func inspect() -> String
}

public extension DLTablable.RowId {
    static let invalid:DLTablable.RowId = 0
}

public extension DLTablable {
    static var tableName: String {
        return "\(self)"
    }
}
