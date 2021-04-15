//
//  TransactionsByCategoryView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 15/04/21.
//

import SwiftUI

struct TransactionsByCategoryView: View {
    
    let category: Catagory
    let componet: Calendar.Component
    let date: Date
    
    @State private var transactions: [Date: [ExpenseItem]] = [:]
    @State private var dates: [Date] = []
    @State private var points: [CGPoint] = []
    
    @State private var numberOfTransactions = 0
    @State private var total: Double = 0.0
    @State private var max = 0.0
    @State private var min = 0.0
    
    init(for category: Catagory, in component: Calendar.Component, of date: Date) {
        self.category = category
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
                                .fontWeight(.medium)
                                .foregroundColor(Colors.subtitle)
                        }
                        
                        VStack {
                            Text(NumberFormatter.currency.string(from: NSNumber(value: max)) ?? "")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(Colors.title)
                            Text("Maximun")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(Colors.subtitle)
                        }
                        
                        VStack {
                            Text(NumberFormatter.currency.string(from: NSNumber(value: min)) ?? "")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(Colors.title)
                            Text("Minimun")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(Colors.subtitle)
                        }
                        
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    //.padding(.horizontal)
                   
                    Chart.Lines(datasource: [
                        //Chart.DataSet(points: self.datasource.points(of: Calendar.gregorian.date(byAdding: .month, value: -1, to: date)!), color: Color(UIColor.systemGroupedBackground)),
                        Chart.DataSet(points: points, color: Color(Colors.primary).opacity(0.8)),
                    ]).frame(height: 120)
                }
                .cardView()
                .padding()

                ForEach(dates, id: \.self) { date in
                    
                    Text(DateFormatter.day.string(from: date))
                        .font(.caption)
                        .foregroundColor(Color.secondary)
                        .padding(.vertical)
                    
                    ForEach(transactions[date, default: []], id: \.self) { transaction in
                        PresentLinkView(destination: ExpenseItemFormView(transaction)) {
                            ExpenseItemView(model: transaction)
                        }
                    }
                }.padding(.horizontal)
   
                
                
               
            }.onAppear {
                
                
                let items = Service.transactions(by: \.category, category, in: componet, of: date)
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
        .navigationTitle(category.name)
    }
}

struct TransactionsByCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsByCategoryView(for: Catagory {$0.name = "1"}, in: .month, of: Date())
        
    }
}
