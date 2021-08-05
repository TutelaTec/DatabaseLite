//
//  DLError.swift
//  DLError
//
//  Created by Mark Morrill on 2021-07-28.
//

import Foundation

struct DLError: Error {
    let msg: String
    init(_ m:String, _ function:String = #function, _ file:String = #file, _ line:Int = #line) {
        msg = m
        DLLogging.log(.error(), m, function, file, line)
    }
}

struct DLDecoderError: Error {
    let msg: String
    init(_ m:String, _ function:String = #function, _ file:String = #file, _ line:Int = #line) {
        msg = m
        DLLogging.log(.error(), m, function, file, line)
    }
}

struct DLDatabaseError: Error {
    let msg: String
    init(_ m:String, _ function:String = #function, _ file:String = #file, _ line:Int = #line) {
        msg = m
        DLLogging.log(.error(), m, function, file, line)
    }
}

struct DLSqliteError: Error {
    let code: Int
    let msg: String
    init( _ r: Int, _ m:String, _ function:String = #function, _ file:String = #file, _ line:Int = #line) {
        code = r
        msg = m
        DLLogging.log(.error(), "\(r): " + m, function, file, line)
    }
}
