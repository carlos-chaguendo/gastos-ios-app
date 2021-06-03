//
//  BudgetFormView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 26/05/21.
//

import SwiftUI

struct BudgetFormView: View {
    @Environment(\.presentationMode) private var presentation
    @ObservedObject private var viewModel: ViewModel
    @State var categories: [Catagory] = []

    init(for category: Catagory? = nil) {
        viewModel = .init(for: category)
        
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    CurrencyTextField(NSLocalizedString("Budget", comment: ":"),
                                      value: $viewModel.amount,
                                      foregroundColor: Colors.Form.value,
                                      accentColor: Colors.Form.value)
                        .font(.title)
                        .frame(height: 50)
                    Text("Category")
                        .font(.caption)
                        .padding(.top)
                        .foregroundColor(Colors.Form.label)
                    LazyVStack {
                        ForEach(categories, id: \.id) { item in
                            Button {
                                self.viewModel.category = item
                                self.viewModel.selectedIdentifiers.removeAll()
                                self.viewModel.selectedIdentifiers.insert(item.id)
                            } label: {
                                HStack {
                                    Color(UIColor.from(hex: UInt32(item.color)))
                                        .frame(width: 8, height: 8)
                                        .cornerRadius(4)
                                    Text(item.name)
                                        .fontWeight(.regular)
                                        .foregroundColor(Colors.Form.value)
                                    Spacer()
                                    if self.viewModel.selectedIdentifiers.contains(item.id) {
                                        Image(systemName: "checkmark")
                                            .imageScale(.medium)
                                            .foregroundColor(Colors.primary)
                                    }
                                }.padding(.bottom)
                            }
                        }
                    }
                    if let previousID = viewModel.previousID {
                        Spacer()
                        Button("Remove Budget") {
                            Service.removeBudget(for: previousID)
                            self.presentation.wrappedValue.dismiss()
                        }
                        .padding(.vertical, 12)
                        .foregroundColor(Color.red)
                    }
                }
            }
            .padding()
            .background(Colors.background)
            .navigationBarTitle("Budget", displayMode: .inline)
            .navigationBarItems(
                leading:
                    Button {
                        self.presentation.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .imageScale(.medium)
                    }
                    .frame(width: 30, height: 30)
                    .foregroundColor(Colors.primary)
                    .offset(x: -8, y: 0),
                
                trailing:
                    Button("Save", action: self.saveAction)
                    .disabled(self.viewModel.selectedIdentifiers.isEmpty)
                    .foregroundColor(Colors.primary)
            )
        }.onAppear {
            /// Solo permite las categorias queaun no tienen presupuesto
            /// o la categoria que se esta editando
            categories = Service.getAll(Catagory.self)
                .filter { $0.budget <= 0 || $0.id == self.viewModel.previousID}
                .sorted { $0.name < $1.name }
            
            Logger.info("Numero de categorias", categories.count)
        }
    }
    
    private func saveAction() {
        guard let category = viewModel.category else {
            return
        }
        
        if let previousID = viewModel.previousID {
            Service.removeBudget(for: previousID)
        }

        category.budget = viewModel.amount ?? 0.0
        Service.addBudget(category)
        self.presentation.wrappedValue.dismiss()
    }
    
    
    
}


extension BudgetFormView {
    class ViewModel: ObservableObject {
        @Published var previousID: Catagory.ID?
        @Published var amount: Double?
        @Published var category: Catagory?
        @Published var selectedIdentifiers = Set<Catagory.ID>()
        
        init(for category: Catagory? = nil) {
            guard let value = category else {
                return
            }
            previousID = category?.id
            amount = value.budget
            selectedIdentifiers.removeAll()
            selectedIdentifiers.insert(value.id)
        }
    }
}

struct BudgetFormView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetFormView()
    }
}
