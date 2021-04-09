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
    
    public var title: LocalizedStringKey
    public var showTotal = true
    
    var body: some View {
        VStack(alignment: .leading) {

            if showTotal {
                HStack {
                    Text(NumberFormatter.currency.string(from: NSNumber(value: total)) ?? "")
                        .font(.title3)
                        .fontWeight(.heavy)
                    
                    Spacer()
                    
                    NavigationLink(destination: Text("s")) {
                        Image(systemName: "chevron.right.circle.fill")
                            .imageScale(.large)
                            .foregroundColor(.quaternaryLabel)
                    }

                }
            }
               
            Text(title)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .padding(.bottom, -3)
            
            GeometryReader { reader in
                HStack(spacing: 0.5) {
                    if categories.isEmpty {
                        Spacer()
                    } else {
                        ForEach(categories, id: \.self) { category in
                                colorsByCategory[category.id, default: .red]
                                    .frame(width: reader.size.width * CGFloat(category.value))
                      
                                    .transition(.leadingX)
                                    .opacity(0.5)
//                            }
                        }
                    }
                    
                }
            }
            .background(Colors.groupedBackground)
            .frame(height: 16)
            .cornerRadius(8.0)
            

            Text(categories.map { $0.name }.joined(separator: " • "))
                .font(.caption2)
                .foregroundColor(Colors.subtitle)
                .padding(.top, -6)

        }

        //.cardView()
        //.animation(.none)
        .onReceive(Publishers.didAddNewTransaction) { item in
            self.fectDataSource(refresh: true)
        }.onReceive(Publishers.didEditTransaction) { item in
            self.fectDataSource(refresh: true)
        }.onAppear {
            self.fectDataSource()
        }
    }
    
    func fectDataSource(refresh: Bool = false) {
        
        if refresh {
            categories.removeAll()
        }
        
        guard categories.isEmpty else {
            return
        }
        
        getValues()
            .receive(on: DispatchQueue.main)
            .sink { values in
                
                Logger.info("Obteneiendo resultados")
                
                    self.categories = values
                    self.colorsByCategory = categories.groupBy { $0.id }.mapValues { _ in
                        Color.random
                    }
                    self.total = categories.map { $0.value }.reduce(0, +)
                
                /// se conviereten los valores a porcentajes del total
                self.categories.forEach { c in
                    c.value = ((c.value * 100)/total)/100
                }
                
            }.store(in: &cancellables)
    }
    
    func getValues() -> Future<[Group], Never> {
        Future { promise in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let result = Service.expenses(by: groupBy, in: Date())
                promise(.success(result))
            }
        }
    }
}

struct GroupPercentGraphView_Previews: PreviewProvider {
    
    static let categories = [
        Catagory {
            $0.name = "One"
            $0.value = 0.25
        },
        Catagory {
            $0.id = "2"
            $0.name = "Comida"
            $0.value = 0.75
        }
    ]
    
    static let colors = [
        "2": Color.green
    ]
    
    static var previews: some View {
        Group {
            
            GroupPercentGraphView(categories: categories, groupBy: \.category, title: "Category")
                .previewLayout(PreviewLayout.fixed(width: 350 , height: 100))
             
            
            GroupPercentGraphView(groupBy: \.category, title: "Wallet")
                .previewLayout(PreviewLayout.fixed(width: 350 , height: 100))
                .preferredColorScheme(.dark)
        }
    }
}
