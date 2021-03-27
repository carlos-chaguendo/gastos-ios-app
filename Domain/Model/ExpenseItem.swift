//
//  ExpenseItem.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 10/03/21.
//

import Foundation


class ExpenseItem: Identifiable {
    
    var title: String
    var value: Double = 0.0
    var tags: [String] = []
    
    init(title: String, value: Double, tags: [String] = []) {
        self.title = title
        self.value = value
        self.tags = tags
    }
    
}
