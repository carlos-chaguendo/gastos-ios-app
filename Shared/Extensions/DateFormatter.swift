//
//  DateFormatter.swift
//  Gastos
//
//  Created by Carlos Andres Chaguendo Sanchez on 12/03/21.
//

import Foundation

extension DateFormatter {
    
    public static var day: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: Locale.preferredLanguages.first ?? "")
        
        if let preferred = Locale.preferredLanguages.first {
            formatter.locale = Locale(identifier: preferred)
        }
        return formatter
    }()
    
    public static var month: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        formatter.locale = Locale(identifier: Locale.preferredLanguages.first ?? "")
        return formatter
    }()
    
    public static var year: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY"
        formatter.locale = Locale(identifier: Locale.preferredLanguages.first ?? "")
        return formatter
    }()
    
}
