//
//  GroupPercentGraphView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 9/04/21.
//

import SwiftUI
import Combine

struct GroupPercentGraphView<Group: Entity & ExpensePropertyWithValue>: View {
    
    @State var total: Double = 0.0
    @State var categories: [Group] = []
    @State var colorsByCategory: [String: Color] = [:]
    
    public let groupBy: KeyPath<ExpenseItem, Group>
    @State public var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Gastos por categoria")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(NumberFormatter.currency.string(from: NSNumber(value: total)) ?? "")
                .font(.title3)
                .fontWeight(.heavy)
                .padding(.bottom, -3)
            
            GeometryReader { reader in
                HStack(spacing: 0) {
                    if categories.isEmpty {
                        Spacer()
                    } else {
                        ForEach(categories, id: \.self) { category in
                            colorsByCategory[category.id, default: .red]
                                .frame(width: reader.size.width * CGFloat(((category.value * 100)/total)/100))
                                .animation(.none)
                                .transition(.leadingX)
                        }
                    }
                    
                }
            }
            .background(Colors.groupedBackground)
            .frame(height: 16)
            .padding(.top, -1)
            
            .cornerRadius(8.0)
            
            
            FlexibleView(data: categories) { item in
                Text(item.name)
                    .font(.caption2)
                    .foregroundColor(Colors.subtitle)
                    .padding(.horizontal, 4)
                
            }
        }

        .cardView()
        .animation(.none)
        .onAppear {
            
            getValues()
                .receive(on: DispatchQueue.main)
                .sink { values in
                    
                    Logger.info("Obteneiendo resultados")
                    
                    
                        self.categories = values
                        self.colorsByCategory = categories.groupBy { $0.id }.mapValues { _ in
                            Color.random
                        }
                        self.total = categories.map { $0.value }.reduce(0, +)
                    
                }.store(in: &cancellables)
        }
    }
    
    func getValues() -> Future<[Group], Never> {
        Future { promise in
            
            //DispatchQueue.main.asyncAfter(deadline: .now()) {
                let result = Service.expenses(by: groupBy, in: Date())
                promise(.success(result))
            //}
            
            
        }
    }
}

struct GroupPercentGraphView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GroupPercentGraphView(groupBy: \.category)
                .previewLayout(PreviewLayout.fixed(width: 350 , height: 100))
                .preferredColorScheme(.dark)
            
            GroupPercentGraphView(groupBy: \.category)
                .previewLayout(PreviewLayout.fixed(width: 350 , height: 100))
        }
    }
}
