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
    
    @State var amount: Double = 4500
    @State var note: String = ""
    @State var newTag: String = ""
    
    @State private var tags = ["Comida", "Seguro"]
    @State private var chekedtags: [String] = []
    
    
    @Binding var isPresented: Bool
    //@Binding var selection: ExpenseItem?
    
    
    public let textChangePublisher = PassthroughSubject<String, Never>()
    
    
    
    
    public func onTextChange( action: @escaping (String) -> Void) -> SubscriptionView<AnyPublisher<String, Never>, Self> {
        
        self.onReceive(textChangePublisher.eraseToAnyPublisher(), perform: action) as! SubscriptionView<AnyPublisher<String, Never>, ExpenseItemFormView>
    }
    
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Gasto")) {
                    
                    
                    TextField("Cuanto", value: $amount, formatter: NumberFormatter.currency)
                        .keyboardType(.numberPad)
                    
                    TextField("Nota", text: $note)
                }
                
                Section(header: Text("Etiqueta")) {
                    HStack {
                        TextField("Nueva Etiqueta", text: $newTag) { editing in
                            Logger.info("new tag editing",editing)
                        } onCommit: {
                            Logger.info("commit validate")
                        }.disableAutocorrection(true)
                        .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification)) { result in
                            
                            Logger.info("result")
                            textChangePublisher.send((result.object as? UITextField)?.text ?? "s")
                        }
                        
                        Button(action: {
                            
                            self.tags.insert(newTag, at: 0)
                            self.chekedtags.append(newTag)
                            self.newTag = ""
                            
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    ForEach(tags, id: \.self) { tag in
                        Button(action: {
                            
                            if let i = chekedtags.firstIndex(of: tag) {
                                chekedtags.remove(at: i)
                            } else {
                                chekedtags.append(tag)
                            }
                            
                        }, label: {
                            HStack{
                                Text(tag)
                                Spacer()
                                if chekedtags.contains(tag) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        })
                    }
                }
                
            }.listStyle(PlainListStyle())
            .navigationBarTitle("New")
            .navigationBarItems(
                leading: Button {
                    self.isPresented = false
                } label: {
                    Image(systemName: "xmark")
                    
                }
                .frame(width: 30, height: 30),
                trailing: Button("Done") {
                    self.isPresented = false
                    let selection = ExpenseItem(title: note, value: Double(amount) , tags: chekedtags)
                    NotificationCenter.default.post(name: .didAddNewTransaction, object: selection)
                }
            )
        }
        
    }
}

struct ExpenseItemFormView_Previews: PreviewProvider {
    
    @State private static var showingDetail = false
    
    static var previews: some View {
        ExpenseItemFormView(isPresented: $showingDetail)
    }
}
