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
    
    @State var amount: String = ""
    @State var note: String = ""
    @State var date = Date()
    
    @State private var wallets = Set<Wallet>()
    @State private var tags = Set<Tag>()
    @State private var categories = Set<Catagory>()
    
    @Environment(\.presentationMode) private var presentation

    public let textChangePublisher = PassthroughSubject<String, Never>()
    
    private let backcolor = Colors.groupedBackground
    private let systemBackground = Colors.background
    
    var body: some View {
        NavigationView {
            VStack {
                
                /// Navigation bar background color
                Color(backcolor)
                    .frame(height: 100)
                
                Color(.red)
                    .frame(height: 20)
                
                RoundedRectangle(cornerRadius: 25.0, style: .circular)
                    .fill(Color(systemBackground))
                    .offset(x: 0, y: -20)
                    .frame(height: 40)
                    .padding(.bottom, -40)
             
//                    .if(colorScheme == .light) {
//                        $0.shadow(color: Color(Colors.shadown),radius: 2, y: -3)
//                    }
                
                List {
                    Section {
                        Row(icon: "dollarsign.square.fill" ) {
                            TextField("Cost", text: $amount)
                                .keyboardType(.numberPad)
                        }
                        
                        Row(icon: "note.text") {
                            TextField("Description", text: $note)
                        }
                        
                        Row(icon: "calendar") {
                            HStack {
                         
                                
                                DatePicker("", selection: $date, displayedComponents: .date)
                                    .labelsHidden()
                                
                                Spacer()
                                
                                Button("Today") {
                                    
                                }
                                
                                Button("Yesterday") {
                                    
                                }
                            }
                        }
                    }
                    
                    Section {
                        PresentLinkView(destination: CategorySelectionView(selection: $categories)) {
                            Row(icon: "square.stack.3d.up.fill", withArrow: true) {
                                ListLabel(items: $categories, empty: "Categories")
                            }
                        }
        
                        PresentLinkView(destination: TagSelectionView(selection: $tags)) {
                            Row(icon: "tag.fill", withArrow: true) {
                                ListLabel(items: $tags, empty: "Tags")
                            }
                        }
                        
                        PresentLinkView(destination: WalletsSelectionView(selection: $wallets)) {
                            Row(icon: "wallet.pass.fill", withArrow: true) {
                                ListLabel(items: $wallets, empty: "Wallet")
                            }
                        }
                
                    }
                    
                    Button("Save") {
                        self.presentation.wrappedValue.dismiss()
                        let selection = ExpenseItem {
                            $0.title = note
                            $0.value = Double(amount) ?? 0.0
                        }
                        Service.addItem(selection)
                    }
                    .listRowBackground(Color(Colors.background))
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0,idealHeight: 40, maxHeight: .infinity)
                    .background(Color(Colors.primary))
                    .foregroundColor(.label)
                    .cornerRadius(16.0)
                    .onAppear {
                        UITableView.appearance().backgroundColor = Colors.groupedBackground
                    }
                }
                .navigationBarTitle("Cost")
                .navigationBarItems(
                    leading: Button {
                        self.presentation.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .frame(width: 30, height: 30)
                )
            }.listStyle(PlainListStyle())
        }
        
    }
    
    public func onTextChange( action: @escaping (String) -> Void) -> SubscriptionView<AnyPublisher<String, Never>, Self> {
        self.onReceive(textChangePublisher.eraseToAnyPublisher(), perform: action) as! SubscriptionView<AnyPublisher<String, Never>, ExpenseItemFormView>
    }
    
    
    @ViewBuilder
    func ListLabel<Value: Entity & EntityWithName>(items: Binding<Set<Value>>, empty: String) -> some View {
        if items.wrappedValue.isEmpty {
            Text(empty)
        } else {
            HStack {
                ForEach(Array(items.wrappedValue), id: \.self) {
                    Text($0.name)
                }
            }
        }
    }
    
    @ViewBuilder
    func Row<Content: View>(icon: String, withArrow: Bool = false, @ViewBuilder buildContent: () -> Content) -> some View {
        HStack {
            Image(systemName: icon)
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
            .preferredColorScheme(.dark)
    }
}
