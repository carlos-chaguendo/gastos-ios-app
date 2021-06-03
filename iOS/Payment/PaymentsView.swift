//
//  PaymentsView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 3/06/21.
//

import SwiftUI
import Combine



class ListViewModel<Element>: ObservableObject {
    @Published var values: [Element] = []
    @Published var showError = false
}

struct PaymentsView: View {
    
    @ObservedObject private var viewModel = ListViewModel<Wallet>()

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.values, id: \.self) { wallet in
                    PresentLinkView(destination: PaymentFormView(for: wallet)) {
                        HStack {
                            Color(UIColor.from(hex: UInt32(wallet.color)))
                                .frame(width: 8, height: 8)
                                .cornerRadius(4)
                            Text(wallet.name)
                                .strikethrough(wallet.isHidden, color: Color(Colors.title))
                                .foregroundColor(Colors.title)
                                .opacity(wallet.isHidden ? 0.4 : 1)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .imageScale(.medium)
                                .foregroundColor(.quaternaryLabel)
                        }
                        .frame(height: 40, alignment: .leading)
                    }.contextMenu {
                        Button("Remove", action: self.remove(wallet))
                        Button(wallet.isHidden ? "Unarchive" : "Archive", action: self.toggleHidden(wallet))
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            
        }
        .background(Colors.background)
        .navigationTitle("Methods of payment")
        .navigationBarItems(
            trailing: PresentLinkView(destination: PaymentFormView()) {
                Image(systemName: "plus")
                    .imageScale(.large)
            }
        ).onReceive(Publishers.didEditWallet) { _ in
            viewModel.values = Service.getAll(Wallet.self).sorted { $0.name < $1.name }
        }.onAppear {
            Logger.info("on Appear nav", type(of: self))
            if viewModel.values.isEmpty {
                viewModel.values = Service.getAll(Wallet.self).sorted { $0.name < $1.name }
            }
        }.alert(isPresented: $viewModel.showError) {
            Alert(title: Text("Error"), message: Text("It is not possible to delete the payment method, because there are transactions related"))
        }
    }
    
    func remove(_ wallet: Wallet) -> () -> Void {
        {
            do {
                try Service.removeWallet(wallet)
            } catch {
                self.viewModel.showError = true
            }
        }
    }
    
    /// Archiva un metodo de pago
    /// - Parameter wallet: metodo de pago
    /// - Returns: 
    func toggleHidden(_ wallet: Wallet) -> () -> Void {
        {
            Service.toggleHidden(value: wallet)
            guard let i = self.viewModel.values.firstIndex(of: wallet) else {
                return
            }
            wallet.isHidden.toggle()
            self.viewModel.values[i] = wallet
        }
    }
}

struct PaymentsView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentsView()
    }
}
