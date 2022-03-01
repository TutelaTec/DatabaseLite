//
//  DLClause.swift
//  
//
//  Created by Mark Morrill on 2022-03-01.
//

import Foundation

public struct DLClause {
    public enum Conjunction: String {
        case first = ""
        case and = "and"
        case or = "or"
    }
    public enum Value {
        case integer(Int)
        case int32(Int32)
        case int64(Int64)
        case double(Double)
        case string(String)
    }
    
    let conjunction: Conjunction
    let column: String
    let value: Value
    fileprivate init(_ con: Conjunction, _ val: Value, _ col: String) {
        column = col
        value = val
        conjunction = con
    }
    public static func first(_ val: Value, _ col: String) -> DLClause {
        return DLClause(.first, val, col)
    }
    public static func and(_ val: Value, _ col: String) -> DLClause {
        return DLClause(.and, val, col)
    }
    public static func or(_ val: Value, _ col: String) -> DLClause {
        return DLClause(.or, val, col)
    }
    
    internal func bind(_ statement: DLStatement, at position:Int) throws {
        switch value {
        case .integer(let i):   try statement.bind(position: position, i)
        case .int32(let i):     try statement.bind(position: position, i)
        case .int64(let i):     try statement.bind(position: position, i)
        case .double(let d):    try statement.bind(position: position, d)
        case .string(let s):    try statement.bind(position: position, s)
        }
    }
}

