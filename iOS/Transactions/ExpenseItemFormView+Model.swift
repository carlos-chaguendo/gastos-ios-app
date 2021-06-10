//
//  ExpenseItemFormView+Model.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 20/05/21.
//

import SwiftUI
import Combine

public class ExpenseItemFormViewModel: ObservableObject {
    private(set) var item: ExpenseItem?

    @Published var amount: Double?
    @Published var note: String = ""
    @Published var date = Date()

    @Published var wallets = Set<Wallet>()
    @Published var tags = Set<Tag>()
    @Published var category: Catagory?

    init() {
        if let current = UserDefaults.standard.value(forKey: "currentDate") as? Date {
            date = current
        }
        
        if let current = UserDefaults.standard.value(forKey: "default-payment-id") as? String,
           let wallet: Wallet = Service.realm.findBy(id: current) {
            wallets.insert(wallet)
        }
    }

    init(_ item: ExpenseItem) {
        self.item = item
        self.amount = item.value
        self.note = item.title
        self.date = item.date
        self.category = item.category
        item.tags.forEach { self.tags.insert($0) }
        self.wallets.insert(item.wallet)
    }

    func getValues() -> ExpenseItem {
        let selection = item ?? ExpenseItem()
        selection.title = note
        selection.value = amount ?? 00
        selection.category = category
        selection.tags.append(objectsIn: tags)
        selection.wallet = wallets.first
        selection.date = date
        return selection
    }
}
