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

    @State var points: [CGPoint] = []

    init(title: LocalizedStringKey, group: KeyPath<ExpenseItem, Group>) {
        self.title = title
        self.datasource = SpendByGroupChartView<Group>.DataSource.init(group: group)
    }

    var body: some View {
        GeometryReader { _ in

            ScrollView {

                VStack(alignment: .leading) {

                    Picker("", selection: $datasource.mode) {
                        ForEach(["D", "W", "M", "Y"], id: \.self) { mode in
                            Text(mode)
                        }
                    }.pickerStyle(SegmentedPickerStyle())

                    HStack {
                        Button(action: datasource.previousPage) {
                            Image(systemName: "chevron.left.circle.fill")
                                .imageScale(.large)
                                .foregroundColor(.quaternaryLabel)
                        }

                        Spacer()
                        Text(DateIntervalFormatter.duration(range: datasource.interval))
                            .foregroundColor(Color.primary)
                        Spacer()

                        Button(action: datasource.nextPage) {
                            Image(systemName: "chevron.right.circle.fill")
                                .imageScale(.large)
                                .foregroundColor(.quaternaryLabel)
                        }

                    }.padding()

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
                                    .frame(width: 4, height: 4)
                                    .cornerRadius(2)

                                Text(category.name)
                                    .font(.system(size: 15))
                                    // .fontWeight(.medium)
                                    .foregroundColor(Colors.title)

                                Text("\(percent.rounded(toPlaces: 2).cleanValue)%")
                                    .font(.caption2)
                                    // .fontWeight(.semibold)
                                    .foregroundColor(Colors.subtitle)

                                Spacer()
                                Text("\(NumberFormatter.currency.string(from: NSNumber(value: category.value)) ?? "")")
                                    .font(.system(size: 15))
                                    .foregroundColor(Colors.title)

                                Image(systemName: "chevron.right")
                                    .imageScale(.medium)
                                    .foregroundColor(.quaternaryLabel)
                            }
                        }.padding(.vertical, 10)

                    }

                }.padding(.horizontal)

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
