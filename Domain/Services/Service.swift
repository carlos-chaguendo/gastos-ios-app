//
//  Service.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 30/03/21.
//

import Foundation
import RealmSwift

public class Service {
    
    
    public static var fileURL = FileManager
        .default
        .containerURL(forSecurityApplicationGroupIdentifier: "group.com.mayorgafirm.gastos.shared")!
        .appendingPathComponent("default.realm")
    
    public static var realm: Realm = {
        
        let fileURL = Service.fileURL
        
        Logger.info("File", Realm.Configuration.defaultConfiguration.fileURL)
        
        let config = Realm.Configuration(
            fileURL: fileURL,
            schemaVersion: 3,
            migrationBlock: { migration, oldSchemaVersion in

                if (oldSchemaVersion < 1) {
        
                }
        })
        Realm.Configuration.defaultConfiguration = config
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
    static func addGroup<Group: Entity & ExpensePropertyWithValue>(_ item: Group) -> Group {
        try! realm.write {
            
            let local: Group = realm.findBy(id: item.id) ?? item
            local.name = item.name
            local.color = item.color
            if local.realm == nil {
                local.id = UUID().description
            }
            
            realm.add(local)
        }
        
        return item.detached()
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
    
    /// Suma de costos por dia
    /// - Parameter date: Fecha
    /// - Returns: Dicionario de costos diarios
    static func sumEventsIn(month date: Date) -> [Date: Double] {
        realm.objects(ExpenseItem.self)
            .filter { $0.date.isSame(.month, to: date) }
            .groupBy { $0.date.withStart(of: .day) }
            .mapValues { $0.map { $0.value}.reduce(0, +) }
    }
    
    static func getItems(in date: Date) -> [ExpenseItem] {
        realm.objects(ExpenseItem.self)
            .filter { Calendar.current.isDate($0.date, equalTo: date, toGranularity: .day) }
            .detached
            .sorted(by: {$0.id > $1.id })
    
    }
    
    static func transactions<Group: Entity & ExpensePropertyWithValue>(by group: KeyPath<ExpenseItem, Group>, _ category: Group, in componet: Calendar.Component, of date: Date) -> [ExpenseItem] {
        realm.objects(ExpenseItem.self)
            .filter { $0.date.isSame(componet, to: date) && $0[keyPath: group].id == category.id }
            .detached
            .sorted(by: {$0.id > $1.id })
    }
    
    static func expenses<Group: Entity & ExpensePropertyWithValue>(by group: KeyPath<ExpenseItem, Group>, in componet: Calendar.Component, of date: Date) -> [Group] {
        
        setColorsIfNeeded(to: Group.self)
        
        let expensesByCategoryId = realm.objects(ExpenseItem.self)
            .filter { $0.date.isSame(componet, to: date) }
            .groupBy { $0[keyPath: group].id }
            .mapValues { $0.map { $0.value}.reduce(0, +) }
        
        let categoriesById = realm.objects(Group.self)
            .groupBy { $0.id }
            .compactMapValues { $0.first }
        
        return expensesByCategoryId.compactMap { categoriId, value -> Group? in
            let category = categoriesById[categoriId]?.detached()
            category?.value = value
            return category
        }
        .sorted(by: { $0.value > $1.value })
        
    }
    
    static func getAll<Object: Entity>(_ type: Object.Type) -> [Object] {
        realm.objects(Object.self)
            .detached
    }
    
    private static func setColorsIfNeeded<Group: Entity & ExpensePropertyWithValue>(to group: Group.Type) {
        let groups = realm.objects(group.self)
            .filter { $0.color == 0x000 }
        
        try! realm.write {
            groups.forEach {
                $0.color = Int32(ColorSpace.random.toHexInt())
            }
        }
    }
    
}
