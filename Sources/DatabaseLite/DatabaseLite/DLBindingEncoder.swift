//
//  DLBindingEncoder.swift
//  DLBindingEncoder
//
//  Created by Mark Morrill on 2021-08-05.
//

import Foundation


class DLBindingEncoder {
    func encode<T: Encodable>(_ value: T) throws -> DLBindings {
        let encoder = DLBindingEncoding()
        try value.encode(to: encoder)
        return encoder.bindings
    }
}

class DLBindingEncoding: Encoder {
    var codingPath: [CodingKey] = []
    let userInfo: [CodingUserInfoKey : Any] = [:]
    
    var bindings: DLBindings = []
    
    func append(binding:DLBinding) {
        bindings += [binding]
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        return KeyedEncodingContainer(DLBindingWriter<Key>(self))
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError("Unimplemented")
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        fatalError("Unimplemented")
    }
}

class DLBindingWriter<K: CodingKey>: KeyedEncodingContainerProtocol {
    typealias Key = K
    var codingPath: [CodingKey] = []
    let parent: DLBindingEncoding
    
    init(_ p: DLBindingEncoding) {
        parent = p
    }
    
    func encodeNil(forKey key: K) throws {
        parent.append(binding: DLBinding(key.stringValue))
    }
    
    func encode(_ value: Bool, forKey key: Key) throws {
        parent.append(binding: DLBinding(key.stringValue, value))
    }
    
    func encode(_ value: String, forKey key: Key) throws {
        parent.append(binding: DLBinding(key.stringValue, value))
    }
    
    func encode(_ value: Double, forKey key: Key) throws {
        parent.append(binding: DLBinding(key.stringValue, value))
    }
    
    func encode(_ value: Float, forKey key: Key) throws {
        parent.append(binding: DLBinding(key.stringValue, value))
    }
    
    func encode(_ value: Int, forKey key: Key) throws {
        parent.append(binding: DLBinding(key.stringValue, value))
    }
    
    func encode(_ value: Int8, forKey key: Key) throws {
        parent.append(binding: DLBinding(key.stringValue, value))
    }
    
    func encode(_ value: Int16, forKey key: Key) throws {
        parent.append(binding: DLBinding(key.stringValue, value))
    }
    
    func encode(_ value: Int32, forKey key: Key) throws {
        parent.append(binding: DLBinding(key.stringValue, value))
    }
    
    func encode(_ value: Int64, forKey key: Key) throws {
        parent.append(binding: DLBinding(key.stringValue, value))
    }
    
    func encode(_ value: UInt, forKey key: Key) throws {
        parent.append(binding: DLBinding(key.stringValue, value))
    }
    
    func encode(_ value: UInt8, forKey key: Key) throws {
        parent.append(binding: DLBinding(key.stringValue, value))
    }
    
    func encode(_ value: UInt16, forKey key: Key) throws {
        parent.append(binding: DLBinding(key.stringValue, value))
    }
    
    func encode(_ value: UInt32, forKey key: Key) throws {
        parent.append(binding: DLBinding(key.stringValue, value))
    }
    
    func encode(_ value: UInt64, forKey key: Key) throws {
        parent.append(binding: DLBinding(key.stringValue, value))
    }
    
    func encode<T>(_ value: T, forKey key: K) throws where T : Encodable {
        fatalError("Unimplemented")
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError("Unimplemented")
    }
    func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        fatalError("Unimplemented")
    }
    func superEncoder() -> Encoder {
        fatalError("Unimplemented")
    }
    func superEncoder(forKey key: K) -> Encoder {
        fatalError("Unimplemented")
    }
}
