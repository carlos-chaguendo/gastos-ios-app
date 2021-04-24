//
//  Logger.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 18/03/21.
//

import os
import Foundation


typealias OSLogger = os.Logger


extension OSLogger {
    
    static let `default` = OSLogger(subsystem: Bundle.main.bundleIdentifier!, category: "default")
    
}

public struct Logger {
    

    public static func info(_ items: String, file: String = #file, line: Int = #line) {
        let other: String? = nil
        self.info(items, other, file: file, line: line)
    }
    
    
    public static func info<Other: Any>(_ items: String, _ other: Other?..., file: String = #file, line: Int = #line) {
        let name = file.components(separatedBy: "/").last ?? file
        let lineName = line < 0 ? "" : ":\(line)"
        
        let others = other.compactMap { $0 }.map {String(describing: $0) }.joined(separator: "\t")
        
        let result =  [items, others].compactMap { $0 }.joined(separator: " ")
        
        let location = "[\(name)\(lineName)]"
       
        OSLogger.default.info("\(location) - \(result)")
    }
    
}


