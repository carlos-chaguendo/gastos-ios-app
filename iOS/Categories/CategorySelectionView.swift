//
//  CategorySelectionView.swift
//  Gastos
//
//  Created by Carlos Andres Chaguendo Sanchez on 31/03/21.
//

import SwiftUI

struct CategorySelectionView: View {

    @State var values: [Catagory] = []
    @Binding var selection: Set<Catagory>

    var body: some View {
        NavigationView {
            SelectorList(
                title: "Categories",
                values: values,
                selected: $selection,
                destination: Text("sss"),
                content: {
                    Text($0.name)
                        .foregroundColor(Colors.Form.value)
                }
            )
            .set(\.allowMultipleSelection, false)

            .onAppear {
                values = Service.getAll(Catagory.self)
            }
        }
    }

}

struct TagSelectionView: View {

    @State var values: [Tag] = []
    @Binding var selection: Set<Tag>

    var body: some View {
        NavigationView {
            SelectorList(
                title: "Tags",
                values: values,
                selected: $selection,
                destination: Text("new Tag"),
                content: {
                    Text($0.name)
                        .foregroundColor(Colors.Form.value)
                }
            )
            .set(\.allowMultipleSelection, true)
            .onAppear {
                values = Service.getAll(Tag.self)
            }
        }
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
                destination: Text("new Wallet"),
                content: {
                    Text($0.name)
                        .foregroundColor(Colors.Form.value)
                }
            )
            .set(\.allowMultipleSelection, false)
            .onAppear {
                values = Service.getAll(Wallet.self)
            }
        }
    }

}
