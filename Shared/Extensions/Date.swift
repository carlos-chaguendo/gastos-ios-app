//
//  Date.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 25/03/21.
//

import Foundation

extension Calendar {
    public static let gregorian = Calendar(identifier: .gregorian)
}


extension Date {
    public func number(of component: Calendar.Component, since date: Date, in timezone: TimeZone = .current ) -> Int {
        var calendar = Calendar.gregorian
        calendar.timeZone = timezone
        let dateCOmponents: DateComponents = calendar.dateComponents([component], from: date, to: self)
        return dateCOmponents.value(for: component)!
    }
}
