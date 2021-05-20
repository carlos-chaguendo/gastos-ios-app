//
//  TransactionsByCategoryView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 15/04/21.
//

import SwiftUI

struct TransactionsByGroupView<Group: Entity & ExpensePropertyWithValue>: View {
    
    let group: Group
    let groupBy: KeyPath<ExpenseItem, Group>
    let componet: Calendar.Component
    let date: Date
    
    @State private var transactions: [Date: [ExpenseItem]] = [:]
    @State private var dates: [Date] = []
    @State private var points: [CGPoint] = []
    
    @State private var numberOfTransactions = 0
    @State private var total: Double = 0.0
    @State private var max = 0.0
    @State private var min = 0.0
    
    @Environment(\.colorScheme) var colorScheme
    
    init(by: KeyPath<ExpenseItem, Group>, for group: Group, in component: Calendar.Component, of date: Date) {
        self.groupBy = by
        self.group = group
        self.componet = component
        self.date = date
    }
    
    let df = DateFormatter()
        .set(\.dateFormat, "EEE\ndd")
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {

                VStack {
                    VStack(alignment: .leading) {
                        Text("Total spending")
                            .font(.caption)
                            .foregroundColor(Colors.subtitle)
                        
                        Text(NumberFormatter.currency.string(from: NSNumber(value: total)) ?? "")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(Colors.title)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        
                    }
                    
                    Chart.Lines(datasource: [
                        Chart.DataSet(points: points, color: Color(UIColor.from(hex: UInt32(group.color))))
                    ]).frame(height: 120)
                }
                .cardView()
                .padding()
                
                VStack(spacing: 0) {
                    ForEach(dates, id: \.self) { date in
                        
                        /// Cada dias
                        HStack(alignment: .top) {
                            Text(df.string(from: date).capitalized)
                                .lineLimit(2)
                                .font(.caption)
                                .foregroundColor(Colors.subtitle)
                                .padding(.top)
                                .frame(width: 60)
                                .frame(minHeight: 40)

                            /// Transacciones de cada dia
                            VStack {
                                ForEach(transactions[date, default: []], id: \.self) { transaction in
                                    PresentLinkView(destination: ExpenseItemFormView(transaction)) {
                                        ExpenseItemView(model: transaction, displayCategory: true)
                                            .padding(.vertical)
                                            .frame(minHeight: 40)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .background(Colors.background)
                            
                        }.padding(.leading)
                    }

                }
                // .background(Color.black.opacity(0.2))
  
            }
            .onAppear {
                
                let items = Service.transactions(by: groupBy, group, in: componet, of: date)
                let values = items.map { $0.value }
                
                self.max = values.max() ?? 0
                self.min = values.min() ?? 0
                self.total = values.reduce(0, +)
                self.numberOfTransactions = items.count
                
                self.transactions = items.groupBy { $0.date.withStart(of: .day) }
                self.dates = Array(transactions.keys).sorted()
                
                let sumByDate = transactions.mapValues { $0.map {$0.value}.reduce(0, +)}
                let range = Calendar.gregorian.dateInterval(of: componet, for: date)!
                let dates = range.enumerate(.day)
                
                var points: [CGPoint] = []
                var x = 0.0
                
                for day in dates {
                    let y = sumByDate[day, default: 0.0]
                    points.append(CGPoint(x: x, y: y))
                    x += 1
                }
                
                self.points = points
            }
        }
        .background(
                ZStack(alignment: .leading) {
                    Color(Colors.background)
                    
                    if self.colorScheme == .dark {
                        Color.black.opacity(0.3)
                            .frame(width: 60 + 20)
                    } else {
                        Color(Colors.primary)
                            .opacity(0.1)
                            .frame(width: 60 + 20)
                    }
                    
                }.background(Color.red)
        )
        .navigationTitle(group.name)
    }
}

struct TransactionsByCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsByGroupView(by: \.category, for: Catagory {$0.name = "1"}, in: .month, of: Date())
            // .preferredColorScheme(.dark)
        
    }
}
