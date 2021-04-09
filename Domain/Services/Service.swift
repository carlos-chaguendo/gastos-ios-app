//
//  Service.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 30/03/21.
//

import Foundation
import RealmSwift


extension Sequence where Iterator.Element: Identifiable {

    /// Crea una versión libre de duplicados de una Array, usando comparaciones de igualdad, en la que sólo se mantiene la primera ocurrencia de cada elemento.
    /// El orden de los valores de los resultados se determina por el orden en que ocurren en el array.
    public var uniq: [Iterator.Element] {
        return self.uniq(by: { element -> Iterator.Element.ID in
            return element.id
        })
    }

}

extension Sequence {

    /// Este método es como `.uniq` excepto que acepta una funcion que se invoca para cada elemento en el array para generar el criterio por el cual se calcula la unicidad.
    /// El orden de los valores de los resultados se determina por el orden en que ocurren en el array. La iteración se invoca con un argumento:
    /// - Parameters:
    ///   - getIdentifier: La funcion invocada por elemento
    /// - Returns: Devuelve el nuevo array libre de duplicados.
    public func uniq<Id: Hashable >(by getIdentifier: (Iterator.Element) -> Id) -> [Iterator.Element] {
        var ids = Set<Id>()
        return self.reduce([]) { uniqueElements, element in
            if ids.insert(getIdentifier(element)).inserted {
                return uniqueElements + CollectionOfOne(element)
            }
            return uniqueElements
        }
    }

    public func groupBy<U: Hashable>(_ keyFunc: (Iterator.Element) -> U) -> [U: [Iterator.Element]] {
        var dict: [U: [Iterator.Element]] = [:]
        for el in self {
            let key = keyFunc(el)
            dict[key, default: []].append(el)
        }
        return dict
    }

    public func countBy<U: Hashable>(_ keyFunc: (Iterator.Element) -> U) -> [U: Int] {
        var dict: [U: Int] = [:]
        for el in self {
            let key = keyFunc(el)
            dict[key, default: 0] += 1
        }
        return dict
    }
    
}

extension Sequence where Iterator.Element: Hashable {

    /// Crea una versión libre de duplicados de una Array, usando comparaciones de igualdad, en la que sólo se mantiene la primera ocurrencia de cada elemento.
    /// El orden de los valores de los resultados se determina por el orden en que ocurren en el array.
    public var uniq: [Iterator.Element] {
        return self.uniq(by: { (element) -> Iterator.Element in
            return element
        })
    }

}


public class Service {
    
    public static var realm: Realm = {
        Logger.info("File", Realm.Configuration.defaultConfiguration.fileURL)
        let realm = try! Realm(configuration: Realm.Configuration.defaultConfiguration)
        return realm
    }()
    
    
    private init() {}
    
    static func addItem(_ item: ExpenseItem) {
        try! realm.write {
            
            let local: ExpenseItem = realm.findBy(id: item.id) ?? item
            
            local.value = item.value
            local.title = item.title
            local.date = item.date
            
            if local.realm == nil {
                local.id = item.date.description
            }
            
            local.category = realm.findBy(id: item.category.id)
            local.wallet = realm.findBy(id: item.wallet.id)
            local.tags = realm.findBy(ids: item.tags)
            
            realm.add(local)
        }

        if item.hasId() {
            NotificationCenter.default.post(name: .didEditTransaction, object: item.detached())
        } else {
            NotificationCenter.default.post(name: .didAddNewTransaction, object: item.detached())
        }
    }
    
    @discardableResult
    static func addCategory(_ item: Catagory) -> Catagory {
        try! realm.write {
            item.id = UUID().description
            realm.add(item)
        }
        
        return item.detached()
    }
    
    static func addTag(_ item: Tag) {
        try! realm.write {
            item.id = UUID().description
            realm.add(item)
        }
    }
    
    static func addWallet(_ item: Wallet) -> Wallet {
        try! realm.write {
            item.id = UUID().description
            realm.add(item)
        }
        
        return item.detached()
    }
    
    static func remove(_ item:ExpenseItem) {
        guard let local = realm.object(ofType: ExpenseItem.self, forPrimaryKey: item.id) else {
            preconditionFailure()
        }
        
        try! realm.write {
            if !local.isInvalidated {
                realm.delete(local)
            }
            Logger.info("Eliminando", local)
        }
    }
    
    static func getItems(in date: Date) -> [ExpenseItem] {
        realm.objects(ExpenseItem.self)
            .filter { Calendar.current.isDate($0.date, equalTo: date, toGranularity: .day) }
            .detached
            .sorted(by: {$0.id > $1.id })
    
    }
    
    /// Retorna todas las fechas que almenos tiene una transaccion
    /// - Parameter date: El mes el cual se quiere consultar
    /// - Returns: description
    static func summaryOf(month date: Date) -> [Date] {
        realm.objects(ExpenseItem.self)
            .filter { Calendar.current.isDate($0.date, equalTo: date, toGranularity: .month)  }
            .map {  Calendar.current.dateInterval(of: .day, for: $0.date)!.start  }
            .uniq
        
    }
    
    static func countEventsIn(month date: Date) -> [Date: Int] {
        realm.objects(ExpenseItem.self)
            .filter { Calendar.current.isDate($0.date, equalTo: date, toGranularity: .month)  }
            .map {  Calendar.current.dateInterval(of: .day, for: $0.date)!.start  }
            .countBy { $0 }
    }
    
    static func sumEventsIn(month date: Date) -> [Date: Double] {
        realm.objects(ExpenseItem.self)
            .filter { $0.date.isSame(.month, to: date) }
            .groupBy { $0.date.withStart(of: .day) }
            .mapValues { $0.map { $0.value}.reduce(0, +) }
    }
    
    static func expenses<Group: Entity & ExpensePropertyWithValue>(by group: KeyPath<ExpenseItem, Group>, in date: Date) -> [Group] {
        let expensesByCategoryId = realm.objects(ExpenseItem.self)
            .filter { $0.date.isSame(.month, to: date) }
            .groupBy { $0[keyPath: group].id }
            .mapValues { $0.map { $0.value}.reduce(0, +) }
        
        let categoriesById = realm.objects(Group.self)
            .groupBy { $0.id }
            .compactMapValues { $0.first }
        
        return expensesByCategoryId.compactMap { categoriId, value -> Group? in
            let category = categoriesById[categoriId]
            category?.value = value
            return category
        }.sorted(by: { $0.value > $1.value })
    }
    

    
    static func getAll<Object: Entity>(_ type: Object.Type) -> [Object] {
        realm.objects(Object.self)
            .detached
    }
    
}
