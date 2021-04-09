//
//  ExpenseGraphView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 8/04/21.
//

import SwiftUI
import Combine

struct ExpenseGraphView: View {
    
    @ObservedObject private var datasource = Datasource()
    @State var needRefreshPageCache = false
    
    var body: some View {
        VStack(alignment: .leading) {

            HStack {
                Picker("", selection: $datasource.mode) {
                    ForEach(datasource.modes, id:\.self) { mode in
                        Text(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(height: 10)
      
                Spacer()
                Image(systemName: "chevron.right.circle.fill")
                    .imageScale(.large)
                    .foregroundColor(.quaternaryLabel)
            }
           
            Text(DateIntervalFormatter.duration(range: datasource.interval))
                .font(.caption2)
                .foregroundColor(.secondary)

            PageView(continuePage: true, needsRefresh: $needRefreshPageCache, currentPage: $datasource.date) { date in
                Chart.Lines(datasource: [
                    //Chart.DataSet(points: self.datasource.points(of: Calendar.gregorian.date(byAdding: .month, value: -1, to: date)!), color: Color(UIColor.systemGroupedBackground)),
                    Chart.DataSet(points: datasource.points, color: Color(Colors.primary).opacity(0.8)),
                ])
               
            } next: { Calendar.current.date(byAdding: datasource.calendarComponent, value: 1, to: $0)!
            } prev: { Calendar.current.date(byAdding: datasource.calendarComponent, value: -1, to: $0)!
            }
            
        }.cardView()
        .onChange(of: datasource.mode) { value in
            Logger.info("Modeo2", value)
            withAnimation {
                self.needRefreshPageCache.toggle()
            }
            //datasource.setInterval(mode: value, date: datasource.date)
        }
        .onReceive(datasource.$date) { nex in
            /// Cuando se cambia la fecha desde la paginacion
            Logger.info("On receibe ", nex)
            //datasource.setInterval(mode: datasource.mode, date: nex)
        }.onAppear {
            datasource.reloadDatasource()
        }
    }
    
}

extension ExpenseGraphView {
    
    class Datasource: ObservableObject {
        
        public var cancellables = Set<AnyCancellable>()
        
        private(set) var modes = ["M", "W"]
        @Published var interval = DateInterval()
        @Published var points: [CGPoint] = []
        @Published var numbers: Int = 0
        @Published var mode = "M" {
            didSet {
                Logger.info("Cambio el modo a ", mode)
                reloadDatasource()
            }
        }
        
        @Published var date =  Date() {
            didSet {
                Logger.info("Cambio la fecha =>", date)
                reloadDatasource()
            }
        }
        
        var calendarComponent: Calendar.Component { mode == "M" ? .month: .weekOfMonth }
        
        init() {
            reloadDatasource()
        }
        
         func reloadDatasource() {
            interval = getInterval(mode: mode, date: date)
            Logger.info("Cargando rsultados")
            self.points = points(of: date)
            self.numbers = points.count        
        }
        
        private func getInterval(mode: String, date: Date = Date()) -> DateInterval {
            let componet = calendarComponent
            let start = date.withStart(of: componet)
            let end = date.withEnd(of: componet)
            return DateInterval(start: start, end: end)
        }
        
        /// Obtiene los puntos para cada dia del mes
        /// - Parameter date: Fecha
        /// - Returns: Puntos
        func points(of date: Date) -> [CGPoint] {
            let componet: Calendar.Component =  mode == "M" ? .month: .weekOfMonth
            let range = Calendar.gregorian.dateInterval(of: componet, for: date)!
            let dates = range.enumerate(.day)
            let events = Service.sumEventsIn(month: date)
            
            var points: [CGPoint] = []
            var x: Double = 0
            
            for day in dates {
                let y = events[day, default: 0.0]
                points.append(CGPoint(x: x, y: y))
                x += 1
            }
            Logger.info("Puntos \(DateFormatter.month.string(from: date))", points.count)
            return points
        }
        
        func getPoints(of date: Date) -> Future<[CGPoint], Never> {
            Future { promise in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    promise(.success(self.points(of: date)))
                }
            }
        }
        
    }
    
}


