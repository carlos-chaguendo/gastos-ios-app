//
//  BudgetChartView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 26/05/21.
//

import SwiftUI
import Combine

struct BudgetChartView: View {
    
    @ObservedObject private var datasource = BudgetView.DataSource()
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Budget")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(Colors.title)
            
            let expe = NumberFormatter.currency.string(from: NSNumber(value: self.datasource.expense)) ?? "n/a"
            let budg = NumberFormatter.currency.string(from: NSNumber(value: self.datasource.budget)) ?? "n/a"
            let available = NumberFormatter.currency.string(from: NSNumber(value: self.datasource.budget - self.datasource.expense)) ?? "n/a"
            let color = Color(Colors.primary)
            
            (Text("\(expe) ") + Text("of") + Text(" \(budg) ") + Text("this month."))
                .font(.system(size: 14))
                .foregroundColor(Colors.subtitle)
            
            LinearProgressView(tint: color, value:  min(self.datasource.expense,  self.datasource.budget), total: self.datasource.budget)
            
            (Text("\(available) ") + Text("remaining"))
                .font(.system(size: 14))
                .foregroundColor(color)
            
        }.onReceive(Publishers.didAddNewTransaction) { _ in
            datasource.load(refresh: true)
        }.onReceive(Publishers.didEditTransaction) { _ in
            datasource.load(refresh: true)
        }.onReceive(Publishers.didEditCategories) { _ in
            datasource.load(refresh: true)
        }.onReceive(Publishers.didEditBudget) { _ in
            datasource.load(refresh: true)
        }.onAppear {
            Logger.info("on Appear nav", type(of: self))
            datasource.load()
        }
    }
}

struct BudgetChartView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetChartView()
            .cardView()
    }
}
