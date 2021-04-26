//
//  WidgetKit.swift
//  WidgetKit
//
//  Created by Carlos Andres Chaguendo Sanchez on 24/04/21.
//

import WidgetKit
import SwiftUI
import Combine

struct Provider<Group: Entity & ExpensePropertyWithValue>: TimelineProvider {
    
    public let groupBy: KeyPath<ExpenseItem, Group>
    
    func placeholder(in context: Context) -> SimpleEntry<Group> {
        SimpleEntry<Group>(date: Date(), source: .init(group: groupBy, categories: [
            Group {
                $0.name = "Category"
                $0.value = 125000
                $0.color = 0x00875a
            },
            Group {
                $0.name = "Yesterday"
                $0.value = 75000
                $0.color = 0xd04437
            },
            Group {
                $0.name = "Expense"
                $0.value = 250000
                $0.color = 0xf4f5f7
            }
        ]))
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry<Group>) -> ()) {
        let entry = placeholder(in: context)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        let currentDate = Date()
        let source = SpendByGroupChartView<Group>.DataSource(group: groupBy)
        let timeline = Timeline(entries: [SimpleEntry(date: currentDate, source: source)], policy: .never)
        
        source.prepareValues()
        completion(timeline)
    }
}

struct SimpleEntry<Group: Entity & ExpensePropertyWithValue>: TimelineEntry {
    let date: Date
    let source: SpendByGroupChartView<Group>.DataSource
}

struct WidgetKitEntryView<Group: Entity & ExpensePropertyWithValue> : View {
    
    var entry: Provider<Group>.Entry
    var title: LocalizedStringKey
    
    var body: some View {
        VStack(spacing: 8) {
            SpendByGroupChartView(datasource: entry.source, title: title, showNavigation: false)
        }.padding()
    }
}



struct ExpenseReportByGroup<Group: Entity & ExpensePropertyWithValue>: View {
    init(title: LocalizedStringKey, group: KeyPath<ExpenseItem, Group>) {
        
    }
    
    var body: some View {
        Text("support")
    }
}


// MARK: - Widget
struct WalletWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "kindx", provider: Provider<Wallet>(groupBy: \.wallet)) { entry in
            WidgetKitEntryView<Wallet>(entry: entry, title: "Wallet")
        }
        .supportedFamilies([.systemMedium, .systemSmall])
        .configurationDisplayName("Wallet")
        .description("Show my expenses by wallet")
    }
}

// MARK: - Widget
struct CategoryWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "kind-gs", provider: Provider<Catagory>(groupBy: \.category)) { entry in
            WidgetKitEntryView<Catagory>(entry: entry, title: "Category")
        }
        .supportedFamilies([.systemMedium, .systemSmall])
        .configurationDisplayName("Category")
        .description("Show my expenses by category")
    }
}

/// # Supporting Multiple Widgets #
/// Es posible configurar multiples widgets `WidgetBundle`
@main
struct WidgetsBundle: WidgetBundle {
    
    @WidgetBundleBuilder
    var body: some Widget {
        WalletWidget()
        CategoryWidget()
    }
    
}
