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
            item.id = item.date.description
            realm.add(item)
        }

        NotificationCenter.default.post(name: .didAddNewTransaction, object: item.detached())
    }
    
    
    static func addCategory(_ item: Catagory) {
        try! realm.write {
            item.id = UUID().description
            realm.add(item)
        }
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
    /// - Returns: <#description#>
    static func summaryOf(month date: Date) -> [Date] {
        realm.objects(ExpenseItem.self)
            .filter { Calendar.current.isDate($0.date, equalTo: date, toGranularity: .month)  }
            .map {  Calendar.current.dateInterval(of: .day, for: $0.date)!.start  }
            .uniq
        
    }
    
    static func getAll<Object: Entity>(_ type: Object.Type) -> [Object] {
        realm.objects(Object.self)
            .detached
    }
    
}


