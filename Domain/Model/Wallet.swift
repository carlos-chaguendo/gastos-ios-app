//
//  Wallet.swift
//  Gastos
//
//  Created by Carlos Andres Chaguendo Sanchez on 31/03/21.
//

import Foundation

class Wallet: Entity, EntityWithName, ExpensePropertyWithValue {
    @objc public dynamic var isHidden = false
    @objc public dynamic var name: String = ""
    @objc public dynamic var color: Int32 = 0x000
    public var value: Double = 0.0
    public var count: Int = 0

    override class func ignoredProperties() -> [String] {
        ["value"]
    }

}

class CreditCart: Wallet {

    @objc public dynamic var paymentDate: Date?
    @objc public dynamic var invoiceDate: Date?

}
