//
//  ChartsView.swift
//  Gastos
//
//  Created by Carlos Andres Chaguendo Sanchez on 6/04/21.
//

import SwiftUI

struct SummaryGraphicsView: View {
    
    private let columns = [
        //      GridItem(.adaptive(minimum: 80)),
        GridItem(.flexible()),
        GridItem(.flexible()),
        //GridItem(.flexible()),
    ]
    
    var body: some View {
        NavigationView {
            
            ScrollView {
                VStack(alignment: .leading) {
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        MaximunDailyExpendingGraphView()
                        SpendChartView()
                    }
   
                    VStack(spacing: 18 ) {
                        SpendByGroupChartView(groupBy: \.category, title: "Category")
                    
                        SpendByGroupChartView(groupBy: \.wallet, title: "Wallet", showTotal: false)
                    }.cardView()
                    
                    TagsChartView()
                        .cardView()
     
                }.padding() // VStack
                
            } // Scroll View
            .navigationBarTitle("Expense",displayMode: .automatic)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            .background(Colors.background)
            
        } // Bottones de navegacion
    }
}

struct ChartsView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            SummaryGraphicsView()
            //.preferredColorScheme(.dark)
            
        }
        
    }
}