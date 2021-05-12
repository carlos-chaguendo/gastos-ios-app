//
//  CategoryFormView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 11/05/21.
//

import SwiftUI

struct CategoryFormView: View {
    
    class ViewModel: ObservableObject {
        
        @Published var name: String = ""
        @Published var color: Color = Color.random
        @Published var type: Int = 0
        
        var category: Catagory? {
            didSet {
                if let item = category {
                    name = item.name
                    color = Color(UIColor.from(hex: UInt32(item.color)))
                    type = item.sign
                }
            }
        }
        
        func getValues() -> Catagory {
            let selection = category ?? Catagory()
            selection.name = name
            selection.color = Int32(color.uicolor.toHexInt())
            selection.sign = type
            return selection
        }
    }
    
    @Environment(\.presentationMode) private var presentation
    @ObservedObject private var viewModel: ViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    form
                }
            }
            .padding()
            .background(Colors.background)
            .navigationBarTitle("Group", displayMode: .inline)
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
                
                trailing: Button(viewModel.category == nil ? "Create" : "Edit") {
                    self.saveAction()
                }.foregroundColor(Colors.primary)
                
            )
        }
    }
    
    @ViewBuilder
    private var form: some View {
        
        SegmentedView([0, 1], selected: $viewModel.type) { type in
            Text(type <= 0 ? "Expenses" : "Revenues")
        }
        
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
    }
    
    init(for item: Catagory? = nil) {
        viewModel = .init()
        viewModel.category = item
        
    }
    
    private func saveAction() {
        let selection = viewModel.getValues()
        Service.addCategory(selection)
        self.presentation.wrappedValue.dismiss()
    }
}

struct CategoryFormView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryFormView()
            .preferredColorScheme(.dark)
    }
}
