//
//  CategorySelectionView.swift
//  Gastos
//
//  Created by Carlos Andres Chaguendo Sanchez on 31/03/21.
//

import SwiftUI
import Combine

struct CategorySelectionView: View {
    
    @State var values: [Catagory] = []
    @Binding var selection: Set<Catagory>
    
    var body: some View {
        NavigationView {
            SelectorList(
                title: "Categories",
                values: values,
                selected: $selection,
                destination: CategoryFormView(),
                header: EmptyView(),
                content: {
                    Text($0.name)
                        .foregroundColor(Colors.Form.value)
                }
            )
            .set(\.allowMultipleSelection, false)
            .background(Colors.background)
            .onAppear {
                values = Service.getAll(Catagory.self)
                    .sorted { $0.name > $1.name }
                    .filter { !$0.isHidden }
            }
        }
    }
    
}

struct TagSelectionView: View {
    
    @State var values: [Tag] = []
    @Binding var selection: Set<Tag>
    
    @State var name: String = ""
    
    @Environment(\.presentationMode) private var presentation
    
    @State private var selectedIdentifiers = Set<Tag.ID>()
    
    var body: some View {
        NavigationView {
            SelectorList(
                title: "Tags",
                values: values,
                selected: $selection,
                destination: EmptyView(),
                header: header,
                addNew: false,
                content: {
                    AnyView(
                        Text($0.name)
                            .foregroundColor(Colors.Form.value)
                    )
                }
            )
            .set(\.allowMultipleSelection, true)
            
        }
        .background(Colors.background)
        .onAppear {
            values = Service.getAll(Tag.self)
                .sorted { $0.name < $1.name }
                .filter { !$0.isHidden }
            
        }
    }
    
    @ViewBuilder var header: some View {
        TextField("New tag", text: $name)
        { isEditing in
            print("Editing")
        } onCommit: {
            print("onCommit")
            let new = Service.addTag(Tag {
                $0.name = self.name
            })
            self.name = ""
            self.values.append(new)
        }
        .font(.title)
        .frame(height: 50)
        .accentColor(Colors.Form.value)
        .foregroundColor(Colors.Form.value)
        .autocapitalization(.words)
        .padding(.top)
        .background(Colors.background)
        .listRowBackground(Color(Colors.background))
    }
    
}

struct WalletsSelectionView: View {
    
    @State var values: [Wallet] = []
    @Binding var selection: Set<Wallet>
    
    var body: some View {
        NavigationView {
            SelectorList(
                title: "Wallet",
                values: values,
                selected: $selection,
                destination: PaymentFormView(),
                header: EmptyView(),
                content: {
                    Text($0.name)
                        .foregroundColor(Colors.Form.value)
                }
            )
            .set(\.allowMultipleSelection, false)
            .onAppear {
                values = Service.getAll(Wallet.self)
                    .sorted { $0.name < $1.name }
                    .filter { !$0.isHidden }
            }
        }
    }
    
}
