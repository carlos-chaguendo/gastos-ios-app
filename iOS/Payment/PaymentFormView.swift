//
//  PaymentFormView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 3/06/21.
//

import SwiftUI

struct PaymentFormView: View {
    
    class ViewModel: ObservableObject {
        @Published var name: String = ""
        @Published var color: Color = Color.random
        @Published var isDefault: Bool = false
        
        var entity: Wallet? {
            didSet {
                guard let item = entity else  { return }
                name = item.name
                color = Color(UIColor.from(hex: UInt32(item.color)))
            }
        }
        
        func getValues() -> Wallet {
            let selection = entity ?? Wallet()
            selection.name = name
            selection.color = Int32(color.uicolor.toHexInt())
            return selection
        }
    }
    
    @Environment(\.presentationMode) private var presentation
    @ObservedObject private var viewModel: ViewModel
    
    @AppStorage("default-payment-id") private var defaultMethodOfPayment: String = "###"
    
    init(for item: Wallet? = nil) {
        viewModel = .init()
        viewModel.entity = item
        viewModel.isDefault = item?.id == defaultMethodOfPayment
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    form
                }
            }
            .padding()
            .background(Colors.background)
            .navigationBarTitle("Wallet", displayMode: .inline)
            .ignoresSafeArea(edges: .bottom)
            .navigationBarItems(
                leading: Button {
                    self.presentation.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .imageScale(.medium)
                }
                .frame(width: 30, height: 30)
                .foregroundColor(Colors.primary)
                .offset(x: -8, y: 0),
                
                trailing: Button(viewModel.entity == nil ? "Add" : "Edit") {
                    self.saveAction()
                }.foregroundColor(Colors.primary)
            )
        }
    }
    
    @ViewBuilder
    private var form: some View {
        TextField("Name", text: $viewModel.name)
            .font(.title)
            .frame(height: 50)
            .accentColor(Colors.Form.value)
            .foregroundColor(Colors.Form.value)
            .autocapitalization(.words)
            .padding(.top)
        
        VStack(alignment: .leading) {
            Text("Color")
                .font(.caption)
                .padding(.bottom, 1)
                .foregroundColor(Colors.Form.label)
            
            ColorPicker("", selection: $viewModel.color)
                .labelsHidden()
                .opacity(0.1)
                .background(viewModel.color.cornerRadius(3.0))
        }.frame(height: 80)
        
        VStack(alignment: .leading) {
            Text("Default payment method")
                .font(.caption)
                .padding(.bottom, 1)
                .foregroundColor(Colors.Form.label)
            
            Toggle("", isOn: $viewModel.isDefault)
                .labelsHidden()
                .accentColor(Colors.primary)
                .toggleStyle(SwitchToggleStyle(tint: Color(Colors.primary)))
        }.frame(height: 80)
    }
    
    private func saveAction() {
        if let defa: Wallet = Service.realm.findBy(id: defaultMethodOfPayment) {
            self.presentation.wrappedValue.dismiss()
            
            
            
            NotificationCenter.default.post(name: .didEditWallet, object: defa.detached)
            return
        }
        
        
        
        
        
        let selection = viewModel.getValues()
        let new = Service.addWallet(selection)
        
        if viewModel.isDefault {
            defaultMethodOfPayment = new.id
        }
    }
}


struct PaymentFormView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentFormView()
    }
}
