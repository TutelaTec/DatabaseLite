//
//  DLColumnNamesDecoder.swift
//  DLColumnNamesDecoder
//
//  Created by Mark Morrill on 2021-08-03.
//

import Foundation

struct DLColumn: CustomStringConvertible {
    let name: String
    let isOptional: Bool
    let type: Any.Type
    
    var description: String {
        return "\(name): \(type)\(isOptional ? "?" : "")"
    }
}


// the first column is presumed to be the primary index
typealias DLColumnNames = [DLColumn]


class DLColumnNamesDecoder {
    func decode<T:Decodable>(_ type: T.Type) throws -> DLColumnNames {
        let decoder = DLColumnNamesDecoding()
        let _ = try type.init(from: decoder)
        return decoder.collected
    }
}

class DLColumnNamesDecoding: Decoder {
    var codingPath: [CodingKey] = []
    let userInfo: [CodingUserInfoKey : Any] = [:]
    var collected: DLColumnNames = []
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        return KeyedDecodingContainer<Key>(DLColumnNamesReader<Key>(self))
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        throw DLDecoderError("Not doing this yet")
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw DLDecoderError("Not doing this yet")
    }
}

class DLColumnNamesReader<K: CodingKey>: KeyedDecodingContainerProtocol {
    typealias Key = K
    var allKeys: [Key] = []
    var codingPath: [CodingKey] = []
    
    let parent: DLColumnNamesDecoding
    var isOptional = false
    var knownKeys = Set<String>()
    
    init(_ p: DLColumnNamesDecoding) {
        parent = p
    }
    
    func appendKey(_ key:Key, _ type:Any.Type) {
        let name = key.stringValue
        if !knownKeys.contains(name) {
            parent.collected.append(DLColumn(name: name, isOptional: isOptional, type: type))
            knownKeys.insert(name)
        }
        isOptional = false
    }
    
    // we will examine every key, so this is always true
    func contains(_ key: K) -> Bool {
        true
    }
    
    func decodeNil(forKey key: K) throws -> Bool {
        isOptional = true
        return false
    }
    
    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        appendKey(key, type)
        return true
    }
    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        appendKey(key, type)
        return 0
    }
    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        appendKey(key, type)
        return 0
    }
    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        appendKey(key, type)
        return 0
    }
    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        appendKey(key, type)
        return 0
    }
    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        appendKey(key, type)
        return 0
    }
    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        appendKey(key, type)
        return 0
    }
    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        appendKey(key, type)
        return 0
    }
    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        appendKey(key, type)
        return 0
    }
    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        appendKey(key, type)
        return 0
    }
    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        appendKey(key, type)
        return 0
    }
    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        appendKey(key, type)
        return 0
    }
    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        appendKey(key, type)
        return 0
    }
    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        appendKey(key, type)
        return ""
    }

    func decode<T>(_ type: T.Type, forKey key: K) throws -> T where T : Decodable {
        // this is where we can handle things like latency min, max, ave
        throw DLDecoderError("Not yet!")
    }

    func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
        throw DLDecoderError("Unimplimented nestedContainer")
    }
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        throw DLDecoderError("Unimplimented nestedUnkeyedContainer for \(key)")
    }
    func superDecoder() throws -> Decoder {
        throw DLDecoderError("Unimplimented superDecoder")
    }
    func superDecoder(forKey key: Key) throws -> Decoder {
        throw DLDecoderError("Unimplimented superDecoder for \(key)")
    }
}

