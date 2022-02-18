//
//  DLBindingEncoder.swift
//  DLBindingEncoder
//
//  Created by Mark Morrill on 2021-08-05.
//

import Foundation


public class DLBindingEncoder {
    public func encode<T: Encodable>(_ value: T) throws -> DLBindings {
        let encoder = DLBindingEncoding()
        try value.encode(to: encoder)
        return encoder.bindings
    }
}

public class DLBindingEncoding: Encoder {
    public var codingPath: [CodingKey] = []
    public let userInfo: [CodingUserInfoKey : Any] = [:]
    
    var bindings: DLBindings = []
    
    public func append(binding:DLBinding) {
        bindings += [binding]
    }
    
    public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        return KeyedEncodingContainer(DLBindingWriter<Key>(self))
    }
    
    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError("Unimplemented")
    }
    
    public func singleValueContainer() -> SingleValueEncodingContainer {
        fatalError("Unimplemented")
    }
}

public class DLBindingWriter<K: CodingKey>: KeyedEncodingContainerProtocol {
    public typealias Key = K
    public var codingPath: [CodingKey] = []
    let parent: DLBindingEncoding
    
    public init(_ p: DLBindingEncoding) {
        parent = p
    }
    
    public func encodeNil(forKey key: K) throws {
        parent.append(binding: DLBinding(key.stringValue))
    }
    
    public func encode(_ value: Bool, forKey key: Key) throws {
        parent.append(binding: DLBinding(key.stringValue, value))
    }
    
    public func encode(_ value: String, forKey key: Key) throws {
        parent.append(binding: DLBinding(key.stringValue, value))
    }
    
    public func encode(_ value: Double, forKey key: Key) throws {
        parent.append(binding: DLBinding(key.stringValue, value))
    }
    
    public func encode(_ value: Float, forKey key: Key) throws {
        parent.append(binding: DLBinding(key.stringValue, value))
    }
    
    public func encode(_ value: Int, forKey key: Key) throws {
        parent.append(binding: DLBinding(key.stringValue, value))
    }
    
    public func encode(_ value: Int8, forKey key: Key) throws {
        parent.append(binding: DLBinding(key.stringValue, value))
    }
    
    public func encode(_ value: Int16, forKey key: Key) throws {
        parent.append(binding: DLBinding(key.stringValue, value))
    }
    
    public func encode(_ value: Int32, forKey key: Key) throws {
        parent.append(binding: DLBinding(key.stringValue, value))
    }
    
    public func encode(_ value: Int64, forKey key: Key) throws {
        parent.append(binding: DLBinding(key.stringValue, value))
    }
    
    public func encode(_ value: UInt, forKey key: Key) throws {
        parent.append(binding: DLBinding(key.stringValue, value))
    }
    
    public func encode(_ value: UInt8, forKey key: Key) throws {
        parent.append(binding: DLBinding(key.stringValue, value))
    }
    
    public func encode(_ value: UInt16, forKey key: Key) throws {
        parent.append(binding: DLBinding(key.stringValue, value))
    }
    
    public func encode(_ value: UInt32, forKey key: Key) throws {
        parent.append(binding: DLBinding(key.stringValue, value))
    }
    
    public func encode(_ value: UInt64, forKey key: Key) throws {
        parent.append(binding: DLBinding(key.stringValue, value))
    }
    
    public func encode<T>(_ value: T, forKey key: K) throws where T : Encodable {
        fatalError("Unimplemented")
    }

    public func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError("Unimplemented")
    }
    public func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        fatalError("Unimplemented")
    }
    public func superEncoder() -> Encoder {
        fatalError("Unimplemented")
    }
    public func superEncoder(forKey key: K) -> Encoder {
        fatalError("Unimplemented")
    }
}
