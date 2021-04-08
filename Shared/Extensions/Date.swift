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
    
    public func isSame(_ component: Calendar.Component, to another: Date, in timezone: TimeZone = .current) -> Bool {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timezone
        let thisComponent: Int = calendar.component(component, from: self)
        let anotherComponent: Int = calendar.component(component, from: another)
        return thisComponent == anotherComponent
    }
    
    public func withStart(of dateComponent: Calendar.Component, timezone: TimeZone = .current) -> Date {
        var startOfComponent = self
        var timeInterval: TimeInterval = 0.0

        var calendar = Calendar.gregorian
        calendar.timeZone = timezone

        _ = calendar.dateInterval(of: dateComponent, start: &startOfComponent, interval: &timeInterval, for: startOfComponent)
        return startOfComponent
    }

    public func withEnd(of dateComponent: Calendar.Component, timezone: TimeZone = .current) -> Date {
        var calendar = Calendar.gregorian
        calendar.timeZone = timezone

        return calendar.date(byAdding: dateComponent, value: 1, to: self.withStart(of: dateComponent, timezone: timezone))!.addingTimeInterval(-1)
    }

}
