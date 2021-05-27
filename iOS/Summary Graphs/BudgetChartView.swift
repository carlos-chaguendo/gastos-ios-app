//
//  BudgetChartView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 26/05/21.
//

import SwiftUI

struct BudgetChartView: View {
    
    @State var loader = ContentLoader.Status.idle
    @State var budget:  Double = 0.0
    @State var expense: Double = 0.0
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Budget")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(Colors.title)
            
  
            let expe = NumberFormatter.currency.string(from: NSNumber(value: self.expense)) ?? "n/a"
            let budg = NumberFormatter.currency.string(from: NSNumber(value: self.budget)) ?? "n/a"
            let available = NumberFormatter.currency.string(from: NSNumber(value: self.budget - self.expense)) ?? "n/a"
            let color = Color(Colors.primary)
            
            (Text("\(expe) ") + Text("of") + Text(" \(budg) ") + Text("this month."))
                .font(.system(size: 14))
                .foregroundColor(Colors.subtitle)
            
            LinearProgressView(tint: color, value:  min(self.expense,  self.budget), total: self.budget)
            
            (Text("\(available) ") + Text("remaining"))
                .font(.system(size: 14))
                .foregroundColor(color)
            
        }.onAppear {
            Logger.info("on Appear nav", type(of: self))
            if case  .idle = loader {
                let values = Service.getBudget()
                self.budget = values.map { $0.budget }.reduce(0.0, +)
                self.expense = values.map { $0.value}.reduce(0, +)
                self.loader = .loaded
                Logger.info("Values", values.count)
            }
        }
    }
}

struct BudgetChartView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetChartView()
            .cardView()
    }
}
