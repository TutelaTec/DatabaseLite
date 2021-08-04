//
//  DLTablable.swift
//  DLTablable
//
//  Created by Mark Morrill on 2021-08-03.
//

import Foundation

protocol DLTablable {
    static var tableName: String {get}
}

extension DLTablable {
    static var tableName: String {
        return "\(self)"
    }
}
