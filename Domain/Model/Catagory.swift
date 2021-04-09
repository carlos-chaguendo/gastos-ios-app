//
//  Catagory.swift
//  Gastos
//
//  Created by Carlos Andres Chaguendo Sanchez on 31/03/21.
//

import Foundation

protocol EntityWithName: class {
    var name: String { get set }
}

protocol ExpensePropertyWithValue: EntityWithName {
    var value: Double { get set }
}

class Catagory: Entity, EntityWithName, ExpensePropertyWithValue {
    @objc public dynamic var name: String = ""
    @objc public dynamic var color = "0xCE0755"
    @objc public dynamic var icon: String = ""
    
    public var value: Double = 0.0
    
    override class func ignoredProperties() -> [String] {
        ["value"]
    }
    
}
