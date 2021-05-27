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
    @State var values: [Catagory] = []
    @State var showAsList = false
    @Namespace var namespace
    @Environment(\.isPreview) var isPreview
    
    let loader = ContentLoader()
    
    var header: some View {
        HStack(alignment: .center) {
            let percent = ((100 * expense) / budget).rounded(toPlaces: 0)
            
            ZStack {
                CircularChart(lineWidth: 4, [
                    .init(color: Color(Colors.primary), value: CGFloat(percent/100)),
                ]).rotationEffect(Angle.degrees(-90))
                
                Text("\(percent.cleanValue)%")
                    .font(.body)
            }
            .frame(width: 70, height: 70)
            
            
            VStack(alignment: .leading) {
                
                (Text("\(NumberFormatter.currency.string(from: NSNumber(value: budget)) ?? "n/a") ") + Text("Budget").font(.system(size: 14)))
                    .foregroundColor(Colors.title)
                
                (Text("\(NumberFormatter.currency.string(from: NSNumber(value: expense)) ?? "n/a") ") + Text("Expense").font(.system(size: 14)))
                    .foregroundColor(Colors.primary)
                
                
                (Text("\(NumberFormatter.currency.string(from: NSNumber(value: budget - expense)) ?? "n/a") ") + Text("remaining").font(.system(size: 14)))
                    
                    .foregroundColor(Colors.subtitle)
                
            }.foregroundColor(Colors.title)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                header
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 2)
                
                /// El lazyVSatck crea las vistas a medida que se nececitan por lo que
                /// llama al onAppear mientras se hace scroll
                LazyVStack(alignment: .leading, spacing: self.showAsList ? 10: 20) {
                    
                    ForEach(values, id: \.self) { category in
                        let expense = NumberFormatter.currency.string(from: NSNumber(value: category.value)) ?? "n/a"
                        let budget = NumberFormatter.currency.string(from: NSNumber(value: category.budget)) ?? "n/a"
                        let available = NumberFormatter.currency.string(from: NSNumber(value: category.budget - category.value)) ?? "n/a"
                        let color = Color(UIColor.from(hex: UInt32(category.color)))
                        
                        VStack(alignment: .leading, spacing: showAsList ? 2 : nil) {
                            HStack {
                                Text(category.name)
                                    .foregroundColor(Colors.title)
                                    .matchedGeometryEffect(id: "title-\(category.id)", in: namespace)
                                Spacer()
                                
                                if self.showAsList {
                                    (Text("\(expense) ") + Text("of") + Text(" \(budget) "))
                                        .font(.system(size: 14))
                                        .foregroundColor(Colors.subtitle)
                                        .matchedGeometryEffect(id: "subtitle\(category.id)", in: namespace)
                                }
                                Image(systemName: "chevron.right.circle.fill")
                                    .imageScale(.large)
                                    .foregroundColor(.quaternaryLabel)
                                    .matchedGeometryEffect(id: "chevron-\(category.id)", in: namespace)
                            }
                            
                            if !self.showAsList {
                                (Text("\(expense) ") + Text("of") + Text(" \(budget) ") + Text("this month."))
                                    .font(.system(size: 14))
                                    .foregroundColor(Colors.subtitle)
                                    .matchedGeometryEffect(id: "subtitle\(category.id)", in: namespace)
                                
                            }
                            
                            LinearProgressView(tint: color, value:  min( category.value,  category.budget), total: category.budget)
                                .matchedGeometryEffect(id: "linear-\(category.id)", in: namespace)
                            
                            (Text("\(available) ") + Text("remaining"))
                                .font(.system(size: 14))
                                .foregroundColor(color)
                                .matchedGeometryEffect(id: "footer-\(category.id)", in: namespace)
                        }
                        .if(!self.showAsList) {
                            $0.cardView()
                            .padding(.horizontal)
                        }
                        
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
           
                    
                }.if(self.showAsList) {
                    $0.cardView()
                        .padding()
                }
                
            } // Scroll View
            .navigationBarTitle("Budget", displayMode: .large)
            .background(Colors.background)
            .navigationBarItems(
                trailing:
                    HStack(spacing: 20) {
                        Button {
                            withAnimation(.spring()) {
                                self.showAsList.toggle()
                            }
                        } label: {
                            Image(systemName: showAsList ? "rectangle.grid.1x2" : "text.alignleft")
                                .imageScale(.large)
                            
                        }
                       
                        
                        PresentLinkView(destination: BudgetFormView()) {
                            Image(systemName: "plus")
                                .imageScale(.large)
                                .frame(width: 40, height: 40)
                        }
                    }
            )
            
        }
        .onAppear {
            Logger.info("on Appear nav", type(of: self))
            if loader.status == .idle && !isPreview {
                values = Service.getBudget()
                budget = values.map { $0.budget }.reduce(0.0, +)
                expense = values.map { $0.value}.reduce(0, +)
                loader.status = .loaded
            }
        }.onReceive(Publishers.MergeMany(Publishers.didEditCategories, Publishers.didEditBudget)) { _ in
            values = Service.getBudget()
            budget = values.map { $0.budget }.reduce(0.0, +)
            expense = values.map { $0.value}.reduce(0, +)
        }
    }
    
    
    
    
}

struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetView(
            budget: 100,
            expense: 75,
            values: [
                Catagory {
                    $0.name = "Casa"
                    $0.value = 23000
                    $0.budget = 80000
                },
                
                Catagory {
                    $0.name = "Car"
                    $0.value = 12000
                    $0.budget = 350000
                }
            ])
        // .preferredColorScheme(.dark)
    }
}
