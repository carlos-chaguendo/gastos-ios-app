//
//  WeekView+Model.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 25/03/21.
//

import Foundation
import CoreGraphics
import SwiftUI

public class WeekendViewModel: ObservableObject {
    
    public struct Row: Hashable {
        let i: Int
        let dates: [Date]
    }
    
    // MARK:  Rangos
   
    @Published public var weekDayNames: [String] = []
    @Published public private(set) var month: DateInterval = DateInterval()
    @Published public private(set) var firstWeek: DateInterval = DateInterval()
    @Published public private(set) var lastWeek: DateInterval = DateInterval()
    @Published public private(set) var datesByWeek: [Row] = []
    
    @Published public private(set) var rowsHeight: CGFloat = 0
    
    @Published public var mode: WeekView.Mode = .weekend {
        didSet {
            calculateRowsHeight()
        }
    }
    
    @Published public var selected = Date() {
        didSet {
            /// >=  el rango incluye el inicio del siguiente periodo
            if selected >= month.end  {
                Logger.info("Listo crearrr un nuevo mes despues")
                createDatesForMonth(in: selected)
            }
            
            if selected < month.start  {
                Logger.info("Listo crearrr un nuevo mes antes")
                createDatesForMonth(in: selected)
            }
            
            NotificationCenter.default.post(name: Notification.Name.WeekView.didSelectDate, object: selected)
        }
    }
    
    /// las fechas en las cuales se les agrega una marca
    ///
    /// la fecha debe de ser al inicio del dia
    @Published public var marked: [Date] = []
    
    public var daysRowHeight: CGFloat = 40 {
        didSet {
            withAnimation(.easeInOut) {
                calculateRowsHeight()
            }
        }
    }
    
    
    /// El numero de la semana en el mes
    public var currentWeekOfMonth: Int { selected.number(of: .weekOfMonth, since: firstWeek.start)}
    
    init(date: Date, mode: WeekView.Mode = .monthly) {
        self.weekDayNames = DateFormatter.day.shortStandaloneWeekdaySymbols
        self.selected = Calendar.current.dateInterval(of: .day, for: date)!.start
        self.mode = .monthly
    }
    
    public func createDatesForMonth(in date: Date) {
        self.month = Calendar.current.dateInterval(of: .month, for: date)!
        self.firstWeek = Calendar.current.dateInterval(of: .weekOfMonth, for: month.start)!
        self.lastWeek = Calendar.current.dateInterval(of: .weekOfMonth, for: month.end)!

        let numberOfDays = lastWeek.end.number(of: .day, since: firstWeek.start)
        var week:[Date] = []
        for i in 0..<numberOfDays {
            week.append(Calendar.gregorian.date(byAdding: .day, value: i, to: firstWeek.start)!)
        }

        datesByWeek = week.chunked(into: 7).enumerated().map() {
            Row(i: $0.offset, dates: $0.element)
        }

        withAnimation(.easeInOut) {
            calculateRowsHeight()
        }
        
        Logger.info("Rango de fechas", firstWeek.start, lastWeek.end)
        Logger.info("Semanas", datesByWeek.count)
    }
    
    private func calculateRowsHeight() {
        switch mode {
        case .weekend: rowsHeight = daysRowHeight
        case .monthly: rowsHeight = daysRowHeight * CGFloat(datesByWeek.count)
        }
    }
    
}
