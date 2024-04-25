//
//  ExpensStackChart.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 27/04/21.
//

import WidgetKit
import SwiftUI
import Combine

struct ExpensStackChartWidget: Widget {

    struct Entry: TimelineEntry {
        var date: Date
        var points: [CGPoint] = []
        var prevpoints: [CGPoint] = []
        var total: Double

    }

    struct Provider: TimelineProvider {

        func placeholder(in context: Context) -> Entry {
            Entry(
                date: Date(),
                points: (1..<31).compactMap { CGPoint(x: $0, y: Int.random(in: 0..<100)) },
                total: 350.000
            )
        }

        func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
            completion(placeholder(in: context))
        }

        func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {

            let date = Date()
            let every = Calendar.Component.month
//            let previousMonth = date.adding(every, value: -1)!

            let expensesByMonth = Service.expenses(in: every, of: date)
                .sorted { $0.key < $1.key }
                .map { CGPoint(x: Double($0.key.component(.day)), y: $0.value)}

//            let expensesByPreviousMonth = Service.expenses(in: every, of: previousMonth)
//                .sorted { $0.key < $1.key }
//                .map { CGPoint(x: Double($0.key.component(.day)), y: $0.value)}

            let total = expensesByMonth.map { $0.y }.reduce(0, +)

            completion(Timeline(entries: [.init(
                date: date,
                points: expensesByMonth,
                // prevpoints: expensesByPreviousMonth,
                total: Double(total)
            )], policy: .never))
        }

    }

    struct ContentView: View {

        @Environment(\.widgetFamily)
        private var widgetFamily

        var entry: Entry

        var body: some View {
            VStack(alignment: .leading) {

                Text(DateFormatter.longMonth.string(from: entry.date))
                    .font(.caption2)
                    .foregroundColor(Colors.subtitle)

                Text(NumberFormatter.currency.string(from: NSNumber(value: entry.total) ) ?? "")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Colors.title)

                Text("Daily spending")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Chart.Lines(datasource: [
                    Chart.DataSet(points: entry.prevpoints, color: Color.gray.opacity(0.2)),
                    Chart.DataSet(points: entry.points, color: Color(Colors.primary))
                ])

            }.padding()
        }

    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "expoense", provider: Provider()) { entry in
            ContentView(entry: entry)
                .widgetBackground(Color.clear)
        }
        .supportedFamilies([.systemMedium, .systemSmall])
        .configurationDisplayName("Expense")
        .description("Stack Chart")
    }

}

struct ExpensStackChart_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ExpensStackChartWidget.ContentView(
                entry: .init(
                    date: Date(),
                    points: [
                        CGPoint(x: 0, y: 10),
                        CGPoint(x: 1, y: 20),
                        CGPoint(x: 2, y: 40),
                        CGPoint(x: 3, y: 80),
                        CGPoint(x: 4, y: 0)
                    ],
                    prevpoints: [
                        CGPoint(x: 0, y: 20),
                        CGPoint(x: 3, y: 50)
                    ],
                    total: 120000
                )
            )
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}
