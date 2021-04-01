//
//  ExpenseItem.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 10/03/21.
//

import Foundation
import Realm
import RealmSwift

class ExpenseItem: Entity {
    
    @objc public dynamic var title: String = ""
    @objc public dynamic var value: Double = 0.0
    @objc public dynamic var date = Date()
    @objc public dynamic var category: Catagory!
    public var tags = List<Tag>()
    @objc public dynamic var wallet: Wallet!
    

    
}
