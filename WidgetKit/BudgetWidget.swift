//
//  BudgetWidget.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 26/05/21.
//

import SwiftUI
import WidgetKit

struct BudgetWidget: Widget {
    
    struct Entry: TimelineEntry {
        var date: Date
        
        var budget:  Double = 0.0
        var expense: Double = 0.0
        
    }
    
    struct Provider: IntentTimelineProvider {
        
        typealias Entry = BudgetWidget.Entry
        typealias Intent = BudgetConfigurationIntent
        
        
        func placeholder(in context: Context) -> Entry {
            .init(date: Date(), budget: 4500, expense: 2500)
        }
        
        func getSnapshot(for configuration: BudgetConfigurationIntent, in context: Context, completion: @escaping (Entry) -> Void) {
            completion(placeholder(in: context))
        }
        
        func getTimeline(for configuration: BudgetConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
            let values = Service.getBudget()
            let entry = Entry(
                date: Date(),
                budget: values.map { $0.budget }.reduce(0.0, +),
                expense: values.map { $0.value}.reduce(0, +)
            )
            completion(Timeline(entries: [entry], policy: .never))
        }
        
    }
    
    struct ContentView: View {
        
        var entry: Entry
        
        var body: some View {
            VStack(alignment: .leading, spacing: 2) {
                let expe = NumberFormatter.currency.string(from: NSNumber(value: entry.expense)) ?? "n/a"
                let budg = NumberFormatter.currency.string(from: NSNumber(value: entry.budget)) ?? "n/a"
                let available = NumberFormatter.currency.string(from: NSNumber(value: entry.budget - entry.expense)) ?? "n/a"
                let color = Color(Colors.primary)
                
                
                let percent = ((entry.expense * 100)/entry.budget/100)
                
                ZStack {
                    CircularChart(animatable: false, lineBackGround: color , [
                        .init(color: color, value: CGFloat(percent))
                    ]).rotationEffect(Angle.degrees(-90))
                    
                    Text("\((percent * 100).rounded(toPlaces: 0).cleanValue)%")
                        .font(.caption2)
                        .foregroundColor(Colors.subtitle)
                    
     
                }
                
                .frame(width: 48, height: 48, alignment: .leading)
                .padding(.vertical, 4)
                
                Text(budg)
                    .font(.headline)
                    .foregroundColor(Colors.title)
                
                
                Text(expe)
                    .font(.headline)
                    .foregroundColor(color)
                
                
                Text(available)
                    .font(.headline)
                    .foregroundColor(Colors.subtitle)
                
                
                
            }
            
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
            .padding()
            
        }
    }
    
    
    var body: some WidgetConfiguration {
        
        IntentConfiguration(kind: "kind-gs-rg2", intent: BudgetConfigurationIntent.self, provider: Provider()) { entry in
//        StaticConfiguration(kind: "kind-gs-rg2", provider: Provider()) { entry in
            
            ContentView(entry: entry)
        }
        .supportedFamilies([.systemSmall])
        .configurationDisplayName("Budget")
        .description("Show budget")
    }
}

struct BudgetWidget_Previews: PreviewProvider {
    static var previews: some View {
        BudgetWidget.ContentView(entry: .init(date: Date(), budget: 4500, expense: 2500))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
