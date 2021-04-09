//
//  ApplicationData.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 8/04/21.
//

import Foundation
import Realm

class ApplicationData: Entity {
    
    @objc public dynamic var currentCalendarDate: Date?
    
    required init() {
        super.init()
        self.id = "-1"
    }
    
    required public init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    required public init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
}
