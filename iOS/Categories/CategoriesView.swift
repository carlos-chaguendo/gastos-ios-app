//
//  CategoriesView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 11/05/21.
//

import SwiftUI
import Combine

struct CategoriesView: View {
    
    @State var values: [Catagory] = []
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(values, id: \.self) { category in
                    
                    PresentLinkView(destination: CategoryFormView(for: category)) {
                        
                        HStack {
                            Color(UIColor.from(hex: UInt32(category.color)))
                                .frame(width: 8, height: 8)
                                .cornerRadius(4)
                            Text(category.name)
                                .foregroundColor(Colors.title)
                            
                            Spacer()
                            if category.sign == 1 {
                                Image(systemName: "arrow.up")
                                    .imageScale(.medium)
                                    .foregroundColor(Colors.primary)
                            }
                            
                            Image(systemName: "chevron.right")
                                .imageScale(.medium)
                                .foregroundColor(.quaternaryLabel)
                        }
                    }
                    .frame(height: 40, alignment: .leading)
                    
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
        }
        .background(Colors.background)
        .navigationTitle("Categories")
        .navigationBarItems(trailing: PresentLinkView(destination: CategoryFormView()) {
            Image(systemName: "plus")
        }).onAppear {
            if values.isEmpty {
                values = Service.getAll(Catagory.self).sorted { $0.name < $1.name }
            }
        }.onReceive(Publishers.didEditCategories) { _ in
            values = Service.getAll(Catagory.self).sorted { $0.name < $1.name }
        }
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView(values: [
            Catagory {
                $0.name = "Casa"
                $0.sign = 1
            },
            Catagory {
                $0.name = "Arro"
                $0.sign = -1
            }
        ])
    }
}
