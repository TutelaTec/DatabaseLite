//
//  DLLogging.swift
//  DLLogging
//
//  Created by Mark Morrill on 2021-07-28.
//

import Foundation

public struct DLLogging {
    public enum Code {
        public enum Level {
            case low
            case medium
            case high
            
            var adjust: Int {
                switch self {
                case .low: return 0
                case .medium: return 50
                case .high: return 99
                }
            }
        }
        case debug(Level = .medium)
        case info(Level = .medium)
        case warning(Level = .medium)
        case error(Level = .medium)
        
        var value: Int {
            switch self {
            case .debug(let level): return 400 + level.adjust
            case .info(let level): return 400 + level.adjust
            case .warning(let level): return 400 + level.adjust
            case .error(let level): return 400 + level.adjust
            }
        }
        
        var abbr: String {
            switch self {
            case .debug(_): return "DBG"
            case .info(_): return "INF"
            case .warning(_): return "WRN"
            case .error(_): return "ERR"
            }
        }
    }
    
    public static func log(_ code:Code, _ msg: String, _ function:String = #function, _ file:String = #file, _ line:Int = #line) {
        NSLog("\(code.abbr) \(code.value) in \(function) at \(NSString(string: file).lastPathComponent):\(line)>\n%@", msg)
    }
}
