//
//  Entity+Detach.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 30/03/21.
//

import Foundation
import Realm
import RealmSwift

protocol RealmListDetachable {
    
    func detached() -> Self
}

extension List: RealmListDetachable where Element: Object {
    
    func detached() -> List<Element> {
        let detached = self.detached
        let result = List<Element>()
        result.append(objectsIn: detached)
        return result
    }
    
}

@objc extension Object {
    
    public func detached() -> Self {
        let detached = type(of: self).init()
        for property in objectSchema.properties {
            guard let value = value(forKey: property.name) else { continue }
            if let detachable = value as? Object {
                detached.setValue(detachable.detached(), forKey: property.name)
            } else if let list = value as? RealmListDetachable {
                detached.setValue(list.detached(), forKey: property.name)
            } else {
                detached.setValue(value, forKey: property.name)
            }
        }
        return detached
    }
}

extension Sequence where Iterator.Element: Object {
    
    public var detached: [Element] {
        return self.map({ $0.detached() })
    }
    
}

extension List {
    
    public func toArray() -> [Element] {
        return Array(self)
    }
    
}

extension Realm {
    public func findBy<E: Entity, Id>(id: Id) -> E? {
        return object(ofType: E.self, forPrimaryKey: id)
    }
    
    public func findBy<Element: Entity>(ids: List<Element>) -> List<Element> {
        let result = List<Element>()
        ids.map { $0.id }
            .compactMap { id -> Element? in
                self.findBy(id: id)
            }
        .forEach { result.append($0)}
        return result
    }
    
}
