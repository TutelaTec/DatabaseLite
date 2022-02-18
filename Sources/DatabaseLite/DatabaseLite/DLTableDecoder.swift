//
//  DLTableDecoder.swift
//  DLTableDecoder
//
//  Created by Mark Morrill on 2021-08-09.
//

import Foundation
import SQLite3

public class DLTableDecoder {
    public func decode<T:Decodable>(_ type: T.Type, from statement:DLStatement) throws -> T {
        let decoder = try DLTableDecoding(statement)
        return try type.init(from: decoder)
    }
}

public class DLTableDecoding: Decoder {
    public var codingPath: [CodingKey] = []
    public let userInfo: [CodingUserInfoKey : Any] = [:]
    public let statement: DLStatement
    let map:[String:Int]
    
    public init(_ stmt: DLStatement) throws {
        var columnMap = [String:Int]()
        let count = stmt.columnCount()
        for index in 0 ..< count {
            let name = try stmt.columnName(position: index)
            columnMap[name] = index
        }
        statement = stmt
        map = columnMap
    }
    
    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        return KeyedDecodingContainer<Key>(DLTableReader<Key>(self))
    }
    
    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        throw DLDecoderError("Not doing this yet")
    }
    
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw DLDecoderError("Not doing this yet")
    }
}

public class DLTableReader<K: CodingKey>: KeyedDecodingContainerProtocol {
    public typealias Key = K
    public var allKeys: [Key] = []
    public var codingPath: [CodingKey] = []
    let parent:DLTableDecoding
    
    public init(_ p: DLTableDecoding) {
        parent = p
    }
    
    public func columnPosition(_ key: Key) throws -> Int {
        guard let pos = parent.map[key.stringValue] else {
            throw DLDatabaseError("Unrecognized key: \(key.stringValue)")
        }
        return pos
    }

    public func contains(_ key: K) -> Bool {
        return nil != parent.map[key.stringValue]
    }
    
    public func decodeNil(forKey key: K) throws -> Bool {
        throw DLDatabaseError("Not doing null yet")
    }
    
    public func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        return parent.statement.columnBool(position: try columnPosition(key))
    }
    public func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        return parent.statement.columnInt(position: try columnPosition(key))
    }
    public func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        return parent.statement.columnInt8(position: try columnPosition(key))
    }
    public func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        return parent.statement.columnInt16(position: try columnPosition(key))
    }
    public func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        return parent.statement.columnInt32(position: try columnPosition(key))
    }
    public func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        return parent.statement.columnInt64(position: try columnPosition(key))
    }
    public func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        return parent.statement.columnUInt(position: try columnPosition(key))
    }
    public func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        return parent.statement.columnUInt8(position: try columnPosition(key))
    }
    public func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        return parent.statement.columnUInt16(position: try columnPosition(key))
    }
    public func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        return parent.statement.columnUInt32(position: try columnPosition(key))
    }
    public func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        return parent.statement.columnUInt64(position: try columnPosition(key))
    }
    public func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        return parent.statement.columnFloat(position: try columnPosition(key))
    }
    public func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        return parent.statement.columnDouble(position: try columnPosition(key))
    }
    public func decode(_ type: String.Type, forKey key: Key) throws -> String {
        return parent.statement.columnText(position: try columnPosition(key))
    }
    
    public func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
        throw DLDatabaseError("Not doing this yet")
    }

    public func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
        throw DLDecoderError("Unimplimented nestedContainer")
    }
    public func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        throw DLDecoderError("Unimplimented nestedUnkeyedContainer for \(key)")
    }
    public func superDecoder() throws -> Decoder {
        throw DLDecoderError("Unimplimented superDecoder")
    }
    public func superDecoder(forKey key: Key) throws -> Decoder {
        throw DLDecoderError("Unimplimented superDecoder for \(key)")
    }
}
