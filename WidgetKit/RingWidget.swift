//
//  RingWidget.swift
//  WidgetKitExtension
//
//  Created by Carlos Andres Chaguendo Sanchez on 29/04/21.
//

import WidgetKit
import SwiftUI
import Combine


// MARK: - Widget
struct RingWidget: Widget {
    
    struct Entry: TimelineEntry {
        var date: Date
    }
    
    struct Provider: TimelineProvider {
        
        func placeholder(in context: Context) -> Entry {
            Entry(date: Date())
        }
        
        func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
            completion(placeholder(in: context))
        }
        
        func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
            completion(Timeline(entries: [Entry(date: Date())], policy: .never))
        }
        
    }
    
    struct ContentView: View {
        
        var entry: Entry
        
        var body: some View {
            VStack(alignment: .leading, spacing: 1) {
                ZStack {
                    CircularChart(animatable: false, lineSpacing: 0.07, lineBackGround: .yellow, [
                        .init(color: .yellow, value: 0.75),
                    ])
                    
                    CircularChart(animatable: false, lineSpacing: 0.09, lineBackGround: .green, [
                        .init(color: .green, value: 0.45),
                    ]).frame(width: 50 - 18)
                    
                    CircularChart(animatable: false, lineSpacing: 0.07, lineBackGround: .blue, [
                        .init(color: .blue, value: 0.25)
                    ]).frame(width: 50 - 18 - 18)
                }.rotationEffect(Angle.degrees(-90))
                .frame(width: 50, height: 50, alignment: .leading)
                .padding(.vertical, 4)
                
                Text("Camisa")
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .font(.headline)
                    .foregroundColor(Colors.title)
                
                Text("Casa la venta")
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .font(.headline)
                    .foregroundColor(Colors.title)
                
                Text("headline")
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .font(.headline)
                    .foregroundColor(Colors.title)
                
                
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .padding()
            
        }
    }
    
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "kind-gs-rg", provider: Provider()) { entry in
            ContentView(entry: entry)
        }
        .supportedFamilies([.systemMedium, .systemSmall])
        .configurationDisplayName("Expenses")
        .description("Show my expenses by category")
    }
}


struct RingWidget_PreviewProvider: PreviewProvider{
    
    
    static var previews: some View {
        RingWidget.ContentView(entry: .init(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
    
}
