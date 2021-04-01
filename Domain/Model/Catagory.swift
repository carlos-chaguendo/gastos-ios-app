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

class Catagory: Entity, EntityWithName {
    @objc public dynamic var name: String = ""
    @objc public dynamic var color = "0xCE0755"
    @objc public dynamic var icon: String = ""
    
}
