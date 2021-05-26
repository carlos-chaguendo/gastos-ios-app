//
//  Catagory.swift
//  Gastos
//
//  Created by Carlos Andres Chaguendo Sanchez on 31/03/21.
//

import Foundation

protocol EntityWithName: AnyObject {
    var name: String { get set }
}

protocol ExpensePropertyWithValue: EntityWithName {
    var value: Double { get set }
    var color: Int32 { get set }
    var count: Int { get set }
}

class Catagory: Entity, EntityWithName, ExpensePropertyWithValue {
    @objc public dynamic var name: String = ""
    @objc public dynamic var color: Int32 = 0x000
    
    /// -1 para egresos. +1 para ingresos
    @objc public dynamic var sign: Int = -1
    
    public var value: Double = 0.0
    public var count: Int = 0
    
    
    @objc public dynamic var budget: Double = 0.0

    override class func ignoredProperties() -> [String] {
        ["value"]
    }

}
