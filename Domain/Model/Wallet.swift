//
//  Wallet.swift
//  Gastos
//
//  Created by Carlos Andres Chaguendo Sanchez on 31/03/21.
//

import Foundation

class Wallet: Entity, EntityWithName {
    
    @objc public dynamic var name: String = ""
    
}

class CreditCart: Wallet {
    
    @objc public dynamic var paymentDate: Date?
    @objc public dynamic var invoiceDate: Date?
    
}
