//
//  CategoriesView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 11/05/21.
//

import SwiftUI
import Combine

struct CategoriesView: View {
    
    @ObservedObject private var viewModel = ListViewModel<Catagory>()
    
    var body: some View {
        ScrollView {
            LazyVStack {
                Text("You can archive categories, so that no new transactions can be added to them.")
                    .font(.caption)
                    .foregroundColor(Colors.subtitle)
                ForEach(viewModel.values, id: \.self) { category in
                    PresentLinkView(destination: CategoryFormView(for: category)) {
                        HStack {
                            Color(UIColor.from(hex: UInt32(category.color)))
                                .frame(width: 8, height: 8)
                                .cornerRadius(4)
                            Text(category.name)
                                .strikethrough(category.isHidden, color: Color(Colors.title))
                                .foregroundColor(Colors.title)
                                .opacity(category.isHidden ? 0.4 : 1)
                            Spacer()
                            if category.sign == 1 {
                                Image(systemName: "arrow.up")
                                    .imageScale(.medium)
                                    .foregroundColor(Colors.primary)
                            }
                            
                            Image(systemName: "chevron.right")
                                .imageScale(.medium)
                                .foregroundColor(.quaternaryLabel)
                        }.frame(height: 40, alignment: .leading)
                    }.contextMenu {
                        Button("Remove", action: self.remove(category))
                        Button(category.isHidden ? "Unarchive" : "Archive", action: self.toggleHidden(category))
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
        }
        .background(Colors.background)
        .navigationTitle("Categories")
        .navigationBarItems(trailing: PresentLinkView(destination: CategoryFormView()) {
            Image(systemName: "plus")
                .imageScale(.large)
        }).onAppear {
            Logger.info("on Appear nav", type(of: self))
            if viewModel.values.isEmpty {
                viewModel.values = Service.getAll(Catagory.self).sorted { $0.name < $1.name }
            }
        }.onReceive(Publishers.didEditCategories) { _ in
            viewModel.values = Service.getAll(Catagory.self).sorted { $0.name < $1.name }
        }.alert(isPresented: $viewModel.showError) {
            Alert(title: Text("Error"), message: Text("It is not possible to delete the category, because there are transactions related"))
        }
    }
    
    func remove(_ category: Catagory) -> () -> Void {
        {
            do {
                try Service.removeCategory(category)
            } catch {
                self.viewModel.showError = true
            }
        }
    }
    
    /// Archiva un metodo de pago
    /// - Parameter wallet: metodo de pago
    /// - Returns:
    func toggleHidden(_ category: Catagory) -> () -> Void {
        {
            Service.toggleHidden(value: category)
            guard let i = self.viewModel.values.firstIndex(of: category) else {
                return
            }
            category.isHidden.toggle()
            self.viewModel.values[i] = category
        }
    }
}
