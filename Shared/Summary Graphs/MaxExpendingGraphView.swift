//
//  MaxExpendingGraphView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 8/04/21.
//

import SwiftUI

struct MaxExpendingGraphView: View {
    
    @ObservedObject private var weekendViewModel: WeekendViewModel
    @State private var eventCount: [Date: Int] = [:]
    
    init() {
        let model = WeekendViewModel(date: Date(), mode: .weekend)
        model.daysRowHeight = 120/7
        model.weekDayNames = DateFormatter.day.veryShortStandaloneWeekdaySymbols
        weekendViewModel = model
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(DateFormatter.longMonth.string(from: weekendViewModel.selected).capitalized)
                .font(.title3)
                .fontWeight(.heavy)
         
            Text("Maximum spending days")
                .font(.caption2)
                .foregroundColor(.secondary)
           
            WeekView(model: weekendViewModel) { date, size in
                AnyView(
                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(.caption2)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                        .background(Colors.primary)
                        .foregroundColor(.white)
                        .opacity(Double.random(in: 0.1..<1))

                )
            }
            .cornerRadius(6)
            .onAppear {
                self.eventCount = Service.countEventsIn(month: weekendViewModel.selected)
            }
        }.cardView()
    }
    
}


