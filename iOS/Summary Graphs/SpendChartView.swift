//
//  ExpenseGraphView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 8/04/21.
//

import SwiftUI
import Combine

struct SpendChartView: View {

    @ObservedObject private var datasource = Datasource()

    var body: some View {
        VStack(alignment: .leading) {

            Text(DateIntervalFormatter.duration(range: datasource.interval))
                .font(.caption2)
                .foregroundColor(Colors.subtitle)

            Text(NumberFormatter.currency.string(from: NSNumber(value: datasource.total) ) ?? "")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(Colors.title)

            Text("Maximun daily spending")
                .font(.caption2)
                .foregroundColor(.secondary)

            HStack {
                Picker("", selection: $datasource.mode) {
                    ForEach(datasource.modes, id: \.self) { mode in
                        Text(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(0)
            }
            .lineLimit(1)
            .padding(.top, -6)

            PageView(continuePage: true, needsRefresh: $datasource.needRefreshPageCache, currentPage: $datasource.date) { _ in
                Chart.Lines(datasource: [
                    // Chart.DataSet(points: self.datasource.points(of: Calendar.gregorian.date(byAdding: .month, value: -1, to: date)!), color: Color(UIColor.systemGroupedBackground)),
                    Chart.DataSet(points: datasource.points, color: Color(Colors.primary).opacity(0.8))
                ])

            } next: { Calendar.current.date(byAdding: datasource.calendarComponent, value: 1, to: $0)!
            } prev: { Calendar.current.date(byAdding: datasource.calendarComponent, value: -1, to: $0)!
            }.frame(height:60)

        }.cardView()
        .onChange(of: datasource.mode) { value in
            Logger.info("Modeo2", value)
            withAnimation {
                self.datasource.needRefreshPageCache.toggle()
            }
        }
        .onReceive(datasource.$date) { nex in
            /// Cuando se cambia la fecha desde la paginacion
            Logger.info("On receibe ", nex)
            // datasource.setInterval(mode: datasource.mode, date: nex)
        }
    }

}

extension SpendChartView {

    class Datasource: ObservableObject {

        public var cancellables = Set<AnyCancellable>()

        private(set) var modes = ["M", "W"]
        @Published var interval = DateInterval()
        @Published var points: [CGPoint] = []
        @Published var numbers: Int = 0
        @Published var total: Double = 0.0
        @Published var needRefreshPageCache = false
        @Published var mode = "W" {
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
            Promise {
                self.reloadDatasource()
            }.sink { _ in
                self.needRefreshPageCache.toggle()
            }.store(in: &cancellables)
        }

         func reloadDatasource() {
            interval = getInterval(mode: mode, date: date)
            Logger.info("Cargando rsultados")
            self.points = points(of: date)
            self.numbers = points.count

            self.total = Double(self.points.map { $0.y }.reduce(0, +))
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

        func getPoints(of date: Date) -> AnyPublisher<[CGPoint], Never> {
            Promise {
               self.points(of: date)
            }.eraseToAnyPublisher()
        }

    }

}
