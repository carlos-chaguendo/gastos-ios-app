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
        return Calendar.gregorian.isDate(self, equalTo: another, toGranularity: component)
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

    /// Genera una colleccion de fechas hasta una fecha, agregando la cantidad de componentes a la siguiente fecha
    /// - Parameters:
    ///   - component: La cantidad de tiempo que existe entre fechas (.day, .hour...)
    ///   - end: La fecha maxima generada o limite del array
    /// - Returns: Devuelve el nuevo array libre de duplicados.
    public func enumerate(_ component: Calendar.Component, until end: Date) -> [Date] {
        var result: [Date] = []
        var currentDate = self

        while currentDate <= end {
            result.append(currentDate)
            currentDate = Calendar.gregorian.date(byAdding: component, value: 1, to: currentDate)!
        }

        return result
    }

    public func component(_ component: Calendar.Component) -> Int {
        Calendar.gregorian.component(component, from: self)
    }

    public func adding(_ component: Calendar.Component, value: Int) -> Date? {
        Calendar.gregorian.date(byAdding: component, value: value, to: self)
    }

}

extension DateInterval {

    public func enumerate(_ component: Calendar.Component) -> [Date] {
        start.enumerate(component, until: end)
    }
}
