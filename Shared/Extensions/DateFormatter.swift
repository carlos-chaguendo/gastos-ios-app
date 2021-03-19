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
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        
        if let preferred = Locale.preferredLanguages.first {
            formatter.locale = Locale(identifier: preferred)
        }
        return formatter
    }()
    
}
