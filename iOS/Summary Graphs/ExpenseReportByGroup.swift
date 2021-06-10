//
//  CategoriesReportView.swift
//  Gastos
//
//  Created by Carlos Andres Chaguendo Sanchez on 9/04/21.
//

import SwiftUI

struct ExpenseReportByGroup<Group: Entity & ExpensePropertyWithValue>: View {

    public var title: LocalizedStringKey?

    @ObservedObject var datasource: SpendByGroupChartView<Group>.DataSource
    @Namespace private var namespace
    @State var points: [CGPoint] = []

    init(title: LocalizedStringKey, group: KeyPath<ExpenseItem, Group>) {
        self.title = title
        self.datasource = SpendByGroupChartView<Group>.DataSource.init(group: group)
    }
    
    var body: some View {
        GeometryReader { _ in

            ScrollView {
 
                SegmentedView(["Day", "Week", "Month", "Year"], selected: $datasource.mode) { mode in
                    Text(LocalizedStringKey(mode))
                }

                VStack(alignment: .leading) {
                    
                    HStack {
                        Button(action: datasource.previousPage) {
                            Image(systemName: "chevron.left.circle.fill")
                                .imageScale(.large)
                                .foregroundColor(.quaternaryLabel)
                        }

                        Spacer()
                        switch datasource.mode {
                        case "Month":
                            Text(DateFormatter.longMonth.string(from: datasource.date))
                                .foregroundColor(Color.primary)
                            
                        case "Year":
                            Text(DateFormatter.year.string(from: datasource.date))
                                .foregroundColor(Color.primary)
                        default:
                            Text(DateIntervalFormatter.duration(range: datasource.interval))
                                .foregroundColor(Color.primary)
                        }
                
                        Spacer()

                        Button(action: datasource.nextPage) {
                            Image(systemName: "chevron.right.circle.fill")
                                .imageScale(.large)
                                .foregroundColor(.quaternaryLabel)
                        }

                    }.padding(.vertical)

                    Text(NumberFormatter.currency.string(from: NSNumber(value: datasource.total)) ?? "")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Colors.title)

                    StackChart<Group>(
                        total: datasource.total,
                        categories: datasource.categories
                    )

                    ForEach(datasource.categories, id: \.self) { category in

                        let percent = (category.value * 100)/datasource.total
                        NavigationLink(destination: TransactionsByGroupView(
                                        by: datasource.groupBy,
                                        for: category,
                                        in: datasource.calendarComponent,
                                        of: datasource.date)) {

                            HStack(alignment: VerticalAlignment.center) {

                                Color(UIColor.from(hex: UInt32(category.color)))
                                    .frame(width: 8, height: 8)
                                    .cornerRadius(4)

                                VStack(alignment: .leading) {
                                    Text(category.name)
                                        .font(.system(size: 15))
                                        .foregroundColor(Colors.title)
                                    
                                    (Text("\(category.count) ") + Text("Transactions"))
                                        .font(.caption2)
                                        .foregroundColor(Colors.subtitle)
                                }

                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text("\(NumberFormatter.currency.string(from: NSNumber(value: category.value)) ?? "")")
                                        .font(.system(size: 15))
                                        .foregroundColor(Colors.title)
                                    Text("\(percent.rounded(toPlaces: 2).cleanValue)%")
                                        .font(.caption2)
                                        .foregroundColor(Colors.subtitle)
                                }
                                
                                Image(systemName: "chevron.right")
                                    .imageScale(.medium)
                                    .foregroundColor(.quaternaryLabel)
                            }
                        }.padding(.vertical)
                        // .matchedGeometryEffect(id: "category-\(category.id)", in: namespace)

                    }

                }
                .padding(.horizontal)

            }
            .padding(.vertical)
            .background(Colors.background)

        }.onAppear {

            guard datasource.categories.isEmpty else {
                return
            }
            datasource.getValuesGrouped()

        }
        .onChange(of: datasource.mode) { mode in

            Logger.info("Cambio el modo a ", mode)
            datasource.getValuesGrouped()

        }
        .navigationBarTitle(self.title!, displayMode: .inline)
    }

}
