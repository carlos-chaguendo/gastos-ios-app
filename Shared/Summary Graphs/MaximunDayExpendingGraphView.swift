//
//  MaxExpendingGraphView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 8/04/21.
//

import SwiftUI
import Combine

struct MaximunDayExpendingGraphView: View {
    
    @ObservedObject private var weekendViewModel: WeekendViewModel
    @State private var eventCount: [Date: Double] = [:]
    @State private var maximumAmount: Double = 0.0
    
    private let defaultOpacity: Double = 0.05
    
    init() {
        let model = WeekendViewModel(date: Date(), mode: .weekend)
        model.daysRowHeight = 120/7
        model.weekDayNames = DateFormatter.day.veryShortStandaloneWeekdaySymbols
        weekendViewModel = model
    }

    var body: some View {
        VStack(alignment: .leading) {
            
            HStack(alignment: VerticalAlignment.firstTextBaseline, spacing: 1) {
                Text(DateFormatter.longMonth.string(from: weekendViewModel.selected).capitalized)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text(DateFormatter.year.string(from: weekendViewModel.selected).capitalized)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }.lineLimit(1)
         
           
            Text(NumberFormatter.currency.string(from: NSNumber(value: maximumAmount) ) ?? "")
                .font(.title3)
                .fontWeight(.heavy)
                
            
            Text("Maximun daily spending")
                .font(.caption2)
                .foregroundColor(.secondary)
            
           
            WeekView(model: weekendViewModel) { date, size in
                AnyView(
                   Text("\(Calendar.current.component(.day, from: date))")
                        .font(.caption2)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                        .background(Colors.primary)
                        .foregroundColor(.white)
                        .opacity(eventCount[date, default: defaultOpacity])
                        .if(!Calendar.current.isDate(weekendViewModel.selected, equalTo: date, toGranularity: .month)) { text in
                            text.hidden()
                        }
                )
            }
            .cornerRadius(6)
            .onReceive(WeekView.didSelectDate) { date in
                didPageChanged()
            }
            .onAppear {
                didPageChanged()
            }
        }.cardView()
    }
    
    private func didPageChanged() {
        Deferred {
            Future<[Date: Double], Never> { promise in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    promise(.success(Service.sumEventsIn(month: weekendViewModel.selected)))
                }
            }
        }
        .eraseToAnyPublisher()
        .receive(on: DispatchQueue.main)
        .sink { events in
            
           // let events = Service.sumEventsIn(month: weekendViewModel.selected)
            let maximumAmount = events.values.max() ?? 0
            let minimunAmount = events.values.min() ?? 0
            
            let opacityRange: Range<Double> = 0..<1
            let ammountRange: Range<Double> = minimunAmount..<maximumAmount
            
            self.eventCount = events
                .mapValues { $0.map(from: ammountRange, to: opacityRange).rounded(toPlaces: 2) }
                .mapValues { max(defaultOpacity, $0
                ) }
            self.maximumAmount = maximumAmount
            Logger.info("Update State")
        }.store(in: &cancellables)
        
  
 
    }
    
    @State
    public var cancellables = Set<AnyCancellable>()
}


struct MaxExpendingGraphView_Previews: PreviewProvider {
    
    
    
    static var previews: some View {
        Group {
            MaximunDayExpendingGraphView()
                .previewLayout(PreviewLayout.fixed(width: 220 , height: 320))
            //.preferredColorScheme(.dark)
            
        }
        
    }
}
