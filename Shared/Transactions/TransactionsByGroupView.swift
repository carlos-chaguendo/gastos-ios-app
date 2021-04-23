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
    
    init(by: KeyPath<ExpenseItem, Group>, for group: Group, in component: Calendar.Component, of date: Date) {
        self.groupBy = by
        self.group = group
        self.componet = component
        self.date = date
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                
           
                VStack {
                    HStack(spacing: 10) {
                        
                        VStack {
                            Text(NumberFormatter.currency.string(from: NSNumber(value: total)) ?? "")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(Colors.title)
                            Text("Total (\(numberOfTransactions))")
                                .font(.caption2)
                                .foregroundColor(Colors.subtitle)
                        }
                        
                        VStack {
                            Text(NumberFormatter.currency.string(from: NSNumber(value: max)) ?? "")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(Colors.title)
                            Text("Maximun")
                                .font(.caption2)
                                .foregroundColor(Colors.subtitle)
                        }
                        
                        VStack {
                            Text(NumberFormatter.currency.string(from: NSNumber(value: min)) ?? "")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(Colors.title)
                            Text("Minimun")
                                .font(.caption2)
                                .foregroundColor(Colors.subtitle)
                        }
                        
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    //.padding(.horizontal)
                   
                    Chart.Lines(datasource: [
                        Chart.DataSet(points: points, color: Color(UIColor.from(hex: UInt32(group.color)))),
                    ]).frame(height: 120)
                }
                .cardView()
                .padding()

                ForEach(dates, id: \.self) { date in
                    
                    Text(DateFormatter.day.string(from: date))
                        .font(.caption)
                        .foregroundColor(Colors.subtitle)
                        .padding(.vertical)
                  
                    ForEach(transactions[date, default: []], id: \.self) { transaction in
                        PresentLinkView(destination: ExpenseItemFormView(transaction)) {
                            ExpenseItemView(model: transaction, displayCategory: false)
                        }
                    }
                }.padding(.horizontal)
  
            }.onAppear {
                
                
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
        .padding(.vertical)
        .navigationTitle(group.name)
        .navigationBarItems(trailing:
                                PresentLinkView(destination: GroupFormView<Group>(group: groupBy, for: group)) {
                Text("Edit")
            }
        )
    }
}

struct TransactionsByCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsByGroupView(by: \.category, for: Catagory {$0.name = "1"}, in: .month, of: Date())
        
    }
}
