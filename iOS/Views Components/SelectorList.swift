//
//  Select.swift
//  Gastos
//
//  Created by Carlos Andres Chaguendo Sanchez on 31/03/21.
//

import SwiftUI
import Combine

struct SelectorList<Content: View, Value: Hashable & Identifiable, Destination: View>: View {

    var title: LocalizedStringKey
    var values: [Value]
    var selected: Binding<Set<Value>>
    var destination: Destination?
    var content: (Value) -> Content
    
    @Environment(\.presentationMode) private var presentation
    @State private var addNew = false
    
    /// Se usa selected identifiers para no sincronizar las vistas con el bindig
    /// solo se sincronizan cuando finaliza el usuario con los botones de done
    @State private var selectedIdentifiers = Set<Value.ID>()

    var allowMultipleSelection = false
    
  

    var body: some View {

        List(selection: selected) {
            Section(header: EmptyView(), footer: footerView) {
                ForEach(values, id: \.id) { item in
                    if allowMultipleSelection {
                        Button {
                            let inseted = self.selectedIdentifiers.insert(item.id).inserted
                            if inseted == false {
                                self.selectedIdentifiers.remove(item.id)
                            }
                        } label: {
                            HStack {
                                content(item)
                                Spacer()
                                Image(systemName: self.selectedIdentifiers.contains(item.id) ? "checkmark.circle.fill": "circle")
                                    .imageScale(.large)
                                    .foregroundColor(Colors.primary)

                            }
                        }

                    } else {
                        Button {
                            self.selected.wrappedValue.removeAll()
                            self.selected.wrappedValue.insert(item)

                            self.selectedIdentifiers.removeAll()
                            self.selectedIdentifiers.insert(item.id)
                            self.presentation.wrappedValue.dismiss()
                        } label: {
                            HStack {
                                content(item)
                                if self.selectedIdentifiers.contains(item.id) {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                        .imageScale(.medium)
                                        .foregroundColor(Colors.primary)
                                }
                            }
                        }
                    }
                }.listRowBackground(Color(Colors.background))
            }
        }
        //        .environment(\.editMode, .constant(allowMultipleSelection ? .active : .inactive))
        .navigationBarTitle(title)
        .listStyle(PlainListStyle())
        .background(Colors.background)
        .navigationBarItems(leading: Button {
            self.presentation.wrappedValue.dismiss()
        } label: {
            Image(systemName: "xmark")
                .imageScale(.medium)
        }, trailing: Button("Done") {
            self.presentation.wrappedValue.dismiss()

            let valuesById = Dictionary(grouping: values, by: { $0.id }).compactMapValues { $0.first }
            selected.wrappedValue.removeAll()

            selectedIdentifiers.forEach {
                Logger.info("seleccionando", $0)
                if let value = valuesById[$0] {
                    selected.wrappedValue.insert(value)
                }
            }

        }).onAppear {
            selected.wrappedValue.forEach {
                selectedIdentifiers.insert($0.id)
            }
        }.foregroundColor(Colors.primary)
    }

    @ViewBuilder var footerView: some View {
        if let addNew = destination {
            VStack {
                PresentLinkView(destination: addNew) {
                    Text("Add New")
                        // .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0,idealHeight: 40, maxHeight: .infinity)
                        // .background(Color(Colors.primary))
                        .foregroundColor(Colors.primary)
                        .cornerRadius(3)
                }

            }.listRowBackground(Color(Colors.background))
        } else {
            EmptyView()
        }
    }
}

struct SelectorList_Previews: PreviewProvider {

    @State private static var categories = Set<Category>()

    static var previews: some View {
        CategorySelectionView(selection: .constant(Set()))
            .preferredColorScheme(.dark)
    }
}
