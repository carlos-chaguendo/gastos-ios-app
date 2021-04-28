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
            schemaVersion: 4,
            migrationBlock: { _, oldSchemaVersion in
                
                if oldSchemaVersion < 1 {
                    
                }
            })
        Realm.Configuration.defaultConfiguration = config
        Logger.info("File", Realm.Configuration.defaultConfiguration.fileURL)
        do {
            let realm = try Realm(configuration: Realm.Configuration.defaultConfiguration)
            return realm
        } catch {
            preconditionFailure(error.localizedDescription)
        }
    }()
    
    private init() {}
    
    static func addItem(_ item: ExpenseItem) {
        realm.rwrite {
            
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
        realm.rwrite {
            
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
        realm.rwrite {
            item.id = UUID().description
            realm.add(item)
        }
        
        return item.detached()
    }
    
    static func addTag(_ item: Tag) {
        realm.rwrite {
            item.id = UUID().description
            realm.add(item)
        }
    }
    
    static func addWallet(_ item: Wallet) -> Wallet {
        realm.rwrite {
            item.id = UUID().description
            realm.add(item)
        }
        
        return item.detached()
    }
    
    static func remove(_ item: ExpenseItem) {
        guard let local = realm.object(ofType: ExpenseItem.self, forPrimaryKey: item.id) else {
            preconditionFailure()
        }
        
        realm.rwrite {
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
    
    /// Cuenta el numero detos por dia
    /// - Returns: Numero de gastos por dia en un mes
    static func countEventsIn(month date: Date) -> [Date: Int] {
        realm.objects(ExpenseItem.self)
            .filter { Calendar.current.isDate($0.date, equalTo: date, toGranularity: .month)  }
            .map {  Calendar.current.dateInterval(of: .day, for: $0.date)!.start  }
            .countBy { $0 }
    }
    
    /// Suma de costos por dia
    /// - Parameter date: Fecha
    /// - Returns: Dicionario de costos diarios, solo las fechas que tiene datos
    static func sumEventsIn(month date: Date) -> [Date: Double] {
        realm.objects(ExpenseItem.self)
            .filter { $0.date.isSame(.month, to: date) }
            .groupBy { $0.date.withStart(of: .day) }
            .mapValues { $0.map { $0.value}.reduce(0, +) }
    }
    
    /// Diccionario de gastos por fehca
    /// - Parameters:
    ///   - componet: El rango de consulta , dia, mes, anio
    ///   - date: la fecha en la cual se requiere buscar
    /// - Returns: datos por dia, Zero si en una fecha no hay transaciones
    static func expenses(in componet: Calendar.Component, of date: Date) -> [Date: Double] {
        let expensesByDay = realm.objects(ExpenseItem.self)
            .filter { $0.date.isSame(componet, to: date) }
            .groupBy { $0.date.withStart(of: .day) }
            .mapValues { $0.map { $0.value}.reduce(0, +) }
        
        let start = date.withStart(of: componet)
        let end = date.withEnd(of: componet)
        let dates = start.enumerate(.day, until: end)
        
        var result: [Date: Double] = [:]
        
        for day in dates {
            result[day] = expensesByDay[day, default: 0.0]
        }
        
        return result
    }
    
    /// Los gastos en un dia
    /// - Parameter date: Dia
    /// - Returns: las transacciones que se realizaron en un dia especificado
    static func getItems(in date: Date) -> [ExpenseItem] {
        realm.objects(ExpenseItem.self)
            .filter { Calendar.current.isDate($0.date, equalTo: date, toGranularity: .day) }
            .detached
            .sorted(by: {$0.id > $1.id })
        
    }
    
    /// Consulta las transacciones por grupo
    /// - Parameters:
    ///   - group: Path para el grupo
    ///   - category: Valor para filtrar
    ///   - componet: El rango de consulta month. year
    ///   - date: la fecha de consulta
    /// - Returns: Listato de transaciones segun una categoria en unas fecha especificas
    static func transactions<Group: Entity & ExpensePropertyWithValue>( by group: KeyPath<ExpenseItem, Group>,
                                                                        _ category: Group, in componet: Calendar.Component,
                                                                        of date: Date
    ) -> [ExpenseItem] {
        realm.objects(ExpenseItem.self)
            .filter { $0.date.isSame(componet, to: date) && $0[keyPath: group].id == category.id }
            .detached
            .sorted(by: {$0.id > $1.id })
    }
    
    /// Consulta los gastos por grupo
    /// - Parameters:
    ///   - group: Path para el grupo
    ///   - componet: Valor para filtrar
    ///   - date: la fecha de consulta
    /// - Returns: Agrupa los gastos en un periodo por grupo
    static func expenses<Group: Entity & ExpensePropertyWithValue>(by group: KeyPath<ExpenseItem, Group>,
                                                                   in componet: Calendar.Component,
                                                                   of date: Date) -> [Group] {
        
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
    
    /// Obtiene todos los elemntos de una entidad
    /// - Parameter type: Entidad
    /// - Returns: Todos los elementos
    static func getAll<Object: Entity>(_ type: Object.Type) -> [Object] {
        realm.objects(Object.self)
            .detached
    }
    
    private static func setColorsIfNeeded<Group: Entity & ExpensePropertyWithValue>(to group: Group.Type) {
        let groups = realm.objects(group.self)
            .filter { $0.color == 0x000 }
        
        realm.rwrite {
            groups.forEach {
                $0.color = Int32(ColorSpace.random.toHexInt())
            }
        }
    }
    
    /// Registra la ultima creacion de un a copia de seguridad
    public static func registreNewBackup() {
        let local = realm.object(ofType: ApplicationData.self, forPrimaryKey: "-1") ?? ApplicationData()
        
        realm.rwrite {
            local.lastBackup = Date()
            realm.add(local, update: .all)
        }
    }
    
    static func getApplicationData() -> ApplicationData {
        realm.object(ofType: ApplicationData.self, forPrimaryKey: "-1")!.detached()
    }
    
}
