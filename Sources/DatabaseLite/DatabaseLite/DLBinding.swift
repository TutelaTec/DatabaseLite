//
//  DLBinding.swift
//  DLBinding
//
//  Created by Mark Morrill on 2021-08-06.
//

import Foundation

typealias DLBindings = [DLBinding]

struct DLBinding : CustomStringConvertible {
    enum Flavour : CustomStringConvertible {
        case null
        case bool(Bool)
        case signed(Int64)
        case unsigned(UInt64)
        case real(Double)
        case text(String)
        
        var description: String {
            switch self {
            case .null:
                return "null"
            case .bool(let bool):
                return bool.description
            case .signed(let int64):
                return int64.description
            case .unsigned(let uInt64):
                return uInt64.description
            case .real(let double):
                return double.description
            case .text(let string):
                return string
            }
        }
    }
    let column: String
    let flavour: Flavour
    
    var description: String {
        return column + ": " + flavour.description
    }
    
    init(_ col:String) {
        column = col
        flavour = .null
    }
    init(_ col: String, _ value:Bool) {
        column = col
        flavour = .bool(value)
    }
    init(_ col: String, _ value:Int) {
        column = col
        flavour = .signed(Int64(value))
    }
    init(_ col: String, _ value:Int8) {
        column = col
        flavour = .signed(Int64(value))
    }
    init(_ col: String, _ value:Int16) {
        column = col
        flavour = .signed(Int64(value))
    }
    init(_ col: String, _ value:Int32) {
        column = col
        flavour = .signed(Int64(value))
    }
    init(_ col: String, _ value:Int64) {
        column = col
        flavour = .signed(value)
    }
    init(_ col: String, _ value:UInt) {
        column = col
        flavour = .unsigned(UInt64(value))
    }
    init(_ col: String, _ value:UInt8) {
        column = col
        flavour = .unsigned(UInt64(value))
    }
    init(_ col: String, _ value:UInt16) {
        column = col
        flavour = .unsigned(UInt64(value))
    }
    init(_ col: String, _ value:UInt32) {
        column = col
        flavour = .unsigned(UInt64(value))
    }
    init(_ col: String, _ value:UInt64) {
        column = col
        flavour = .unsigned(value)
    }
    init(_ col: String, _ value:Double) {
        column = col
        flavour = .real(value)
    }
    init(_ col: String, _ value:Float) {
        column = col
        flavour = .real(Double(value))
    }
    init(_ col: String, _ value:String) {
        column = col
        flavour = .text(value)
    }

    
    func bind(with stmt:DLStatement, at postion:Int) throws {
        switch flavour {
        case .null:
            try stmt.bindNull(position: postion)
        case .bool(let bool):
            try stmt.bind(position: postion, bool)
        case .signed(let int):
            try stmt.bind(position: postion, int)
        case .unsigned(let int):
            try stmt.bind(position: postion, int)
        case .real(let double):
            try stmt.bind(position: postion, double)
        case .text(let string):
            try stmt.bind(position: postion, string)
        }
    }
}
