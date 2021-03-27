//
//  WeekView+Model.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 25/03/21.
//

import SwiftUI

public class WeekendViewModel: ObservableObject {
    
    // MARK:  Rangos
   
    @Published public private(set) var month: DateInterval = DateInterval()
    @Published public private(set) var firstWeek: DateInterval = DateInterval()
    @Published public private(set) var lastWeek: DateInterval = DateInterval()
    @Published public private(set) var datesByWeek: [[Date]] = []
    
    @Published public var selected = Date() {
        didSet {
            if selected > lastWeek.end  {
                Logger.info("Listo crearrr un nuevo mes despues")
                createDatesForMonth(in: selected)
            }
            
            if selected < firstWeek.start  {
                Logger.info("Listo crearrr un nuevo mes antes")
                createDatesForMonth(in: selected)
            }
            
            NotificationCenter.default.post(name: Notification.Name.WeekView.didSelectDate, object: selected)
        }
    }
    
    
    /// El numero de la semana en el mes
    public var currentWeekOfMonth: Int { selected.number(of: .weekOfMonth, since: firstWeek.start)}
    
    init(date: Date) {
        self.selected = Calendar.current.dateInterval(of: .day, for: date)!.start
    }
    
    private func createDatesForMonth(in date: Date) {
        self.month = Calendar.current.dateInterval(of: .month, for: date)!
        self.firstWeek = Calendar.current.dateInterval(of: .weekOfMonth, for: month.start)!
        self.lastWeek = Calendar.current.dateInterval(of: .weekOfMonth, for: month.end)!

        let numberOfDays = lastWeek.end.number(of: .day, since: firstWeek.start)
        var week:[Date] = []
        for i in 0..<numberOfDays {
            week.append(Calendar.gregorian.date(byAdding: .day, value: i, to: firstWeek.start)!)
        }

        datesByWeek = week.chunked(into: 7)
    }
    
}
