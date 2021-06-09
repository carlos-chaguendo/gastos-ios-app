//
//  BudgetView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 26/05/21.
//

import SwiftUI
import Combine

struct BudgetView: View {
    
    @Namespace private var namespace
    @Environment(\.isForXcocePreview) private var isForXcodePreview
    @AppStorage("budget-show-as-list") private var showAsList: Bool = false
    @ObservedObject private var datasource = DataSource()
    
    var header: some View {
        HStack(alignment: .center) {
            let percent = ((100 * datasource.expense) / datasource.budget).rounded(toPlaces: 0)
            
            ZStack {
                CircularChart(lineWidth: 4 ) {
                    .init(color: Color(Colors.primary), value: CGFloat(percent/100))
                }.rotationEffect(Angle.degrees(-90))
                Text("\(percent.cleanValue)%")
                    .font(.body)
            }
            .frame(width: 70, height: 70)
            .padding(.vertical, 3)
            
            
            VStack(alignment: .leading) {
                
                //                ( + Text("Budget").font(.system(size: 14)))
                //                    .foregroundColor(Colors.title)
                
                (Text("\(currency(from: datasource.expense)) ") + Text("of") + Text(" \(currency(from: datasource.budget))"))
                    .foregroundColor(Colors.subtitle)
                
                (Text("\(currency(from: datasource.budget - datasource.expense)) ") + Text("remaining"))
                    .foregroundColor(Colors.primary)
                
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
                    
                    ForEach(datasource.values, id: \.self) { category in
                        let expense = NumberFormatter.currency.string(from: NSNumber(value: category.value)) ?? "n/a"
                        let budget = NumberFormatter.currency.string(from: NSNumber(value: category.budget)) ?? "n/a"
                        let available = NumberFormatter.currency.string(from: NSNumber(value: category.budget - category.value)) ?? "n/a"
                        let color = Color(UIColor.from(hex: UInt32(category.color)))
                        PresentLinkView(destination: BudgetFormView(for: category) ) {
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
                    }.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    
                    
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
                            
                            if showAsList {
                                Image(systemName: "rectangle.grid.1x2")
                                    .font(.system(size: 17, weight: .medium))
                                    .imageScale(.large)
                            } else {
                                Image(systemName: "text.alignleft")
                                    .imageScale(.large)
                            }
                            
                        }
                        PresentLinkView(destination: BudgetFormView()) {
                            Image(systemName: "plus")
                                .imageScale(.large)
                                .frame(width: 40, height: 40)
                        }
                    }
            )
            
        }
        .onReceive(Publishers.MergeMany(Publishers.didEditCategories, Publishers.didEditBudget)) { _ in
            datasource.load(refresh: true)
        }
        .onReceive(Publishers.MergeMany(Publishers.didEditTransaction, Publishers.didAddNewTransaction)) { _ in
            datasource.load(refresh: true)
        }
        .onAppear {
            Logger.info("on Appear nav", type(of: self))
            if datasource.loader == .idle && !isForXcodePreview {
                datasource.load()
            }
        }
    }
    
    private func currency(from value: Double) -> String {
        NumberFormatter.currency.string(from: NSNumber(value: value)) ?? "n/a"
    }
}

extension BudgetView {
    
    class DataSource: ObservableObject, PropertyBuilder {
        @Published var loader = ContentLoader.Status.idle
        @Published var budget:  Double = 1.0
        @Published var expense: Double = 0.0
        @Published var values: [Catagory] = []
        
        public var cancellables = Set<AnyCancellable>()
        
        func load(refresh: Bool = false) {
            if refresh {
                loader = .idle
            }
            
            if case .idle = loader {
                Promise {
                    Service.getBudget()
                }.sink { values in
                    self.budget = values.map { $0.budget }.reduce(0.0, +)
                    self.expense = values.map { $0.value}.reduce(0, +)
                    self.loader = .loaded
                    self.values = values
                    Logger.info("Values", values.count)
                }.store(in: &cancellables)
            }
        }
        
    }
    
}

struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetView()
        // .preferredColorScheme(.dark)
    }
}
