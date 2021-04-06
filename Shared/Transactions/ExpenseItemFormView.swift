//
//  ExpenseItemFormView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 10/03/21.
//

import SwiftUI
import UIKit
import Combine


struct ExpenseItemFormView: View {
    
    @State var amount: Double?
    @State var note: String = ""
    @State var date = Date()
    
    @State private var wallets = Set<Wallet>()
    @State private var tags = Set<Tag>()
    @State private var categories = Set<Catagory>()
    
    @Environment(\.presentationMode) private var presentation
    
    public let textChangePublisher = PassthroughSubject<String, Never>()
    
    private let backcolor = Colors.groupedBackground
    private let systemBackground = Colors.background
    
    
    func setup( block: (Self) -> Self ) -> Self {
        return  block(self)
    }
    
    var body: some View {
        NavigationView {
            
            ScrollView {
                VStack {
                    
                    CurrencyTextField("Transaction value", value: $amount, foregroundColor: Colors.Form.label, accentColor: Colors.Form.label)
                    .font(.title)
                    .frame(height: 50)
                    
                    TextField("Description", text: $note)
                        .font(.body)
                        .frame(height: 50)
                        .accentColor(Colors.Form.label)
                        .foregroundColor(Colors.Form.label)
                        .autocapitalization(.words)
                    
                    /// Date picker
                    HStack {
                        Button("Today") {}
                            .padding()
                            .frame(height: 34)
                            .background(.secondarySystemBackground)
                            .accentColor(Color(Colors.subtitle))
                            .cornerRadius(3.0)
                        
                        Button("Yesterday") {}
                            .padding()
                            .frame(height: 34)
                            .background(.secondarySystemBackground)
                            .accentColor(Color(Colors.subtitle))
                            .cornerRadius(3.0)
                        
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                            .labelsHidden()
                            .accentColor(Color(Colors.subtitle))
                            .background(.secondarySystemBackground)
                            .foregroundColor(.red)
                            .cornerRadius(3.0)
                        Spacer()
                    }.frame(height: 50)
                    
                    /// Categories picker
                    PresentLinkView(destination: CategorySelectionView(selection: $categories)) {
                        Row(icon: "square.stack.3d.up.fill", withArrow: true) {
                            ListLabel(items: $categories, empty: "Categories")
                        }
                    }//.frame(height: 60)
                    
                    /// Tags picker
                    PresentLinkView(destination: TagSelectionView(selection: $tags)) {
                        Row(icon: "tag.fill", withArrow: true) {
                            TagsLabel(items: $tags, empty: "Tags")
                        }
                    }
                    
                    /// Wallet picker
                    PresentLinkView(destination: WalletsSelectionView(selection: $wallets)) {
                        Row(icon: "wallet.pass.fill", withArrow: true) {
                            ListLabel(items: $wallets, empty: "Wallet")
                        }
                    }

                    Spacer()
                    
                }
            }
            .padding()
            .navigationBarTitle("Expense",displayMode: .inline)
            .navigationBarItems(
                leading: Button {
                    self.presentation.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .imageScale(.medium)
                }
                //.frame(width: 30, height: 30)
                .foregroundColor(Colors.primary),
                
                trailing: Button("Create") {
                    self.saveAction()
                }.foregroundColor(Colors.primary)
                
            )
        }
        
    }
    
    private func saveAction() {
        let selection = ExpenseItem {
            $0.title = note
            $0.value = amount ?? 00
            $0.category = self.categories.first
            $0.tags.append(objectsIn: self.tags)
            $0.wallet = self.wallets.first
        }
        
        Service.addItem(selection)
        self.presentation.wrappedValue.dismiss()
    }
    
    public func onTextChange( action: @escaping (String) -> Void) -> SubscriptionView<AnyPublisher<String, Never>, Self> {
        self.onReceive(textChangePublisher.eraseToAnyPublisher(), perform: action) as! SubscriptionView<AnyPublisher<String, Never>, ExpenseItemFormView>
    }
    
    
    @ViewBuilder
    func ListLabel<Value: Entity & EntityWithName>(items: Binding<Set<Value>>, empty: String) -> some View {
        if items.wrappedValue.isEmpty {
            Text(empty)
                .padding(.vertical)
                .accentColor(Colors.Form.label)
        } else {
            VStack(alignment: .leading) {
                Text(empty)
                    .font(.caption)
                    .padding(.bottom, 1)
                    .accentColor(Colors.Form.label)
                
                ForEach(Array(items.wrappedValue), id: \.self) {
                    Text($0.name)
                        .foregroundColor(Colors.Form.value)
                }
                
                
            }.padding(.vertical)
        }
    }
    
    @ViewBuilder
    func TagsLabel<Value: Entity & EntityWithName>(items: Binding<Set<Value>>, empty: String) -> some View {
        if items.wrappedValue.isEmpty {
            Text(empty)
                .padding(.vertical)
                .accentColor(Colors.Form.label)
        } else {
            VStack(alignment: .leading) {
                Text(empty)
                    .font(.caption)
                    .padding(.bottom, 1)
                    .accentColor(Colors.Form.label)
                
                FlexibleView(data: items.wrappedValue) { item in
                    Text(verbatim: item.name)
                        .font(.callout)
                        // .fontWeight(.medium)
                        .padding(3)
                        .foregroundColor(Colors.Form.value)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.secondarySystemBackground))
                            //.fill(Color.gray.opacity(0.2))
                        )
                }//.padding(.top, -6)
            }.padding(.vertical)
            
            
        }
    }
    
    @ViewBuilder
    func Row<Content: View>(icon: String, withArrow: Bool = false, @ViewBuilder buildContent: () -> Content) -> some View {
        HStack {
            //Image(systemName: icon)
            buildContent()
            if withArrow {
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.secondary)
                    .imageScale(.small)
            }
        }
    }
    
}

struct ExpenseItemFormView_Previews: PreviewProvider {
    
    @State private static var showingDetail = false
    
    static var previews: some View {
        ExpenseItemFormView()
            .setup {
                $0.note =  "Nota descriptiva"
                
                return $0
            }
            .preferredColorScheme(.dark)
    }
}
