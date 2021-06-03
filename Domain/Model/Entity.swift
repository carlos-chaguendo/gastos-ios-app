//
//  File.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 30/03/21.
//

import Foundation
import Realm
import RealmSwift

open class Entity: Object, Identifiable {

    @objc public dynamic var id: String = "0x0"

    required public init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }

    required public init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }

    public required init() {
        super.init()
    }

    func hasId() -> Bool {
        id != "0x0"
    }

    open override class func primaryKey() -> String? {
        "id"
    }
    
//    deinit {
//        Logger.info("Eliminando", type(of: self))
//    }

}

public protocol Then {}

extension Then where Self: Object {

    public init(block: (Self) -> Void) {
        self.init()
        block(self)
    }

}

extension Object: Then {}
