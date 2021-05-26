//
//  BudgetView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 26/05/21.
//

import SwiftUI
import Combine

struct BudgetView: View {
    
    @State var budget:  Double = 0.0
    @State var expense: Double = 0.0
    
    @State var values: [Catagory] = [] {
        didSet {
            budget = values.map { $0.budget }.reduce(0.0, +)
            expense = values.map { $0.value}.reduce(0, +)
        }
    }
    

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    
                    HStack(alignment: .center) {
                        CircularChart(lineWidth: 4, [
                            .init(color: Color.primary, value: 0.333),
                        ])
                        .frame(width: 20, height: 20)
                        
                        
                        (
                            Text("\(NumberFormatter.currency.string(from: NSNumber(value: expense)) ?? "n/a") ") +
                                Text("of") +
                                Text(" \(NumberFormatter.currency.string(from: NSNumber(value: budget)) ?? "n/a") ") +
                                Text("planificado")
                            
                        )
                        .foregroundColor(Colors.subtitle)
                        
                        
                    }.padding(.top, 2)
                    
                    ForEach(values, id: \.self) { category in
                        
                        VStack(alignment: .leading) {
                            
                            HStack {
                                Text(category.name)
                                    .foregroundColor(Colors.title)
                                Spacer()
                                
                                Image(systemName: "chevron.right.circle.fill")
                                    .imageScale(.large)
                                    .foregroundColor(.quaternaryLabel)
                            }
                            
                            let expense = NumberFormatter.currency.string(from: NSNumber(value: category.value)) ?? "n/a"
                            let budget = NumberFormatter.currency.string(from: NSNumber(value: category.budget)) ?? "n/a"
                            let available = NumberFormatter.currency.string(from: NSNumber(value: category.budget - category.value)) ?? "n/a"
                            let color = Color(UIColor.from(hex: UInt32(category.color)))
                            
                            (Text("\(expense) ") + Text("of") + Text(" \(budget) ") + Text("this month."))
                                .font(.system(size: 14))
                                .foregroundColor(Colors.subtitle)
                            
                            
                            LinearProgressView(tint: color, value:  min( category.value,  category.budget), total: category.budget)
                            
                            
                            (Text("\(available) ") + Text("remaining"))
                                .font(.system(size: 14))
                                .foregroundColor(color)
                            
                        }
                        
                        .cardView()
                        
                    }
                    
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
            }
            .background(Colors.background)
            .navigationBarTitle("Budget", displayMode: .large)
            .navigationBarItems(
                trailing: PresentLinkView(destination: BudgetFormView()) {
                    Image(systemName: "plus")
                    imageScale(.large)
                })
            .onAppear {
                if values.isEmpty {
                    values = Service.getBudget()
                }
            }.onReceive(Publishers.MergeMany(Publishers.didEditCategories, Publishers.didEditBudget)) { _ in
                values = Service.getBudget()
            }
            
        }
    }
}

struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetView(values: [
            Catagory {
                $0.name = "Casa"
                $0.value = 25000
                $0.budget = 80000
            },
            
            Catagory {
                $0.name = "Car"
                $0.value = 12000
                $0.budget = 350000
            }
        ])
        .preferredColorScheme(.dark)
    }
}
