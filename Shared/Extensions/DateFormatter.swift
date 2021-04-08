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
    
    public static var longMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
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

extension DateIntervalFormatter {
    /// Describe el periodo transcurrido entre 2 fechas
    ///
    ///     Feb 22 → 25, 2020
    ///     Ene 10, 2020
    /// - Parameter range: Rango de fecha
    @available(OSX 10.12, *)
    @available(tvOS, unavailable)
    public class func duration(range: DateInterval, in timezone: TimeZone = .current) -> String {
        let format = DateFormatter()
        format.timeZone = timezone
        let startDate = range.start
        let endDate = range.end

        if startDate.isSame(.day, to: endDate, in: timezone) == true && startDate.isSame(.month, to: endDate, in: timezone) == true {
            format.dateFormat = "MMM dd, yyyy"
            return format.string(from: endDate)
        }

        format.dateFormat = startDate.isSame(.year, to: endDate, in: timezone) ? "MMM dd" : "MMM dd, yyyy"
        let start = format.string(from: startDate)

        format.dateFormat = startDate.isSame(.month, to: endDate, in: timezone) ? "dd, yyyy" : "MMM dd, yyyy"
        let end = format.string(from: endDate)

        return "\(start) → \(end)"
    }
}
