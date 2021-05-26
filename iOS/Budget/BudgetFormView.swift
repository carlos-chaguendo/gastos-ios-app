//
//  BudgetFormView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 26/05/21.
//

import SwiftUI

struct BudgetFormView: View {
    @Environment(\.presentationMode) private var presentation
    @ObservedObject private var viewModel: ExpenseItemFormViewModel
    @State var categories: [Catagory] = []
    @State private var selectedIdentifiers = Set<Catagory.ID>()
    
    
    init() {
        viewModel = .init()
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    
                    CurrencyTextField(NSLocalizedString("Budget", comment: ":"), value: $viewModel.amount, foregroundColor: Colors.Form.value, accentColor: Colors.Form.value)
                        .font(.title)
                        .frame(height: 50)
                    
                    Text("Category")
                        .font(.caption)
                        .padding(.top)
                        .foregroundColor(Colors.Form.label)
                    
                    LazyVStack {
                        ForEach(categories, id: \.id) { item in
                            Button {
                                self.viewModel.categories.removeAll()
                                self.viewModel.categories.insert(item)
                                
                                self.selectedIdentifiers.removeAll()
                                self.selectedIdentifiers.insert(item.id)
                                
                            } label: {
                                HStack {
                                    
                                    Color(UIColor.from(hex: UInt32(item.color)))
                                        .frame(width: 8, height: 8)
                                        .cornerRadius(4)
                                    
                                    Text(item.name)
                                        .fontWeight(.regular)
                                        .foregroundColor(Colors.Form.value)
                                    
                                    Spacer()
                                    
                                    if self.selectedIdentifiers.contains(item.id) {
                                      
                                        Image(systemName: "checkmark")
                                            .imageScale(.medium)
                                            .foregroundColor(Colors.primary)
                                    }
                                }
                                .padding(.bottom)
                                
                            }
                        }
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
                    Button("Save") {
                        self.saveAction()
                    }
                    .disabled(self.selectedIdentifiers.isEmpty)
                    .foregroundColor(Colors.primary)
          
            )
        }.onAppear {
            categories = Service.getAll(Catagory.self)
            Logger.info("Numero de categorias", categories.count)
        }
    }
    
    private func saveAction() {
        guard
            let id = selectedIdentifiers.first,
            let category = categories.first(where: { $0.id == id })
             else {
            return
        }
        
        category.budget = viewModel.amount ?? 0.0
        Service.addBudget(category)
        self.presentation.wrappedValue.dismiss()
    }
    

    
}

struct BudgetFormView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetFormView()
    }
}
