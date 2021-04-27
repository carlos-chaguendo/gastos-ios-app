//
//  GroupFormView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 15/04/21.
//

import SwiftUI

internal class GroupFormViewModel<Group: Entity & ExpensePropertyWithValue>: ObservableObject {
    var item: Group?
    @Published var name: String = ""
    @Published var color: Color = Color.random
    @Published var type: String = "Gasto"
    
    func getValues() -> Group {
        let selection = item ?? Group()
        selection.name = name
        selection.color = Int32(color.uicolor.toHexInt())
        return selection
    }
}

struct GroupFormView<Group: Entity & ExpensePropertyWithValue>: View {
    
    @Environment(\.presentationMode) private var presentation
    @ObservedObject private var viewModel: GroupFormViewModel<Group>
    
    init(group: KeyPath<ExpenseItem, Group>, for item: Group? = nil) {
        viewModel = .init()
        viewModel.item = item
        
        if let item = item {
            viewModel.name = item.name
            viewModel.color = Color(UIColor.from(hex: UInt32(item.color)))
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    
                    TextField("Name", text: $viewModel.name)
                        .font(.title)
                        .frame(height: 50)
                        .accentColor(Colors.Form.value)
                        .foregroundColor(Colors.Form.value)
                        .autocapitalization(.words)
                    
                    

                    VStack(alignment: .leading) {
                        Text("Color")
                        .font(.caption)
                        .padding(.bottom, 1)
                        .foregroundColor(Colors.Form.label)
                        
                        ColorPicker("", selection: $viewModel.color)
                            .labelsHidden()
                            //.overlay(viewModel.color.cornerRadius(3.0))
                            .background(viewModel.color.cornerRadius(3.0))
                    }.frame(height: 80)
                    
                    
                    VStack(alignment: .leading) {
                        Text("Tipo de transacion")
                        .font(.caption)
                        .padding(.bottom, 1)
                        .foregroundColor(Colors.Form.label)
                        
                        Picker("", selection: $viewModel.type) {
                            ForEach(["Ingreso", "Gasto"], id:\.self) { mode in
                                Text(mode)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                    }.frame(height: 80)
                    
                    Spacer()
                    
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
                
                trailing: Button(viewModel.item == nil ? "Create" : "Edit") {
                    self.saveAction()
                }.foregroundColor(Colors.primary)
                
            )
        }
    }
    
    private func saveAction() {
        let selection = viewModel.getValues()
        Service.addGroup(selection)
        self.presentation.wrappedValue.dismiss()
    }
}

struct GroupFormView_Previews: PreviewProvider {
    static var previews: some View {
        GroupFormView<Catagory>(group: \.category, for: nil)
    }
}
