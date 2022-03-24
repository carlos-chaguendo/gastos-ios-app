//
//  AlertView+Model.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 9/02/22.
//

import Foundation
import Combine
import SwiftUI

struct AlertInfo: Identifiable {
    
    let id: String
    let title: String
    let message: String
    let actions: [AlertAction]
    
    init(title: String, message: String,  @ArrayBuilder<AlertAction> _ makeActions: () -> [AlertAction]) {
        self.id = title
        self.title = title
        self.message = message
        self.actions = makeActions()
    }
    
}

struct AlertAction: Identifiable {
    let id: String
    let action: () -> Void
    
    init(_ id: String, action: @escaping () -> Void) {
        self.id = id
        self.action = action
    }
    
    init(_ id: String) {
        self.init(id, action: {})
    }
    
    static func cancel() -> AlertAction {
        AlertAction("Cancel") {}
    }
    
    static func cancel(action: @escaping () -> Void) -> AlertAction {
        AlertAction("Cancel", action: action)
    }
}

/// Modelo encargado de administrar la informacion de las alertas
class AlertViewController: ObservableObject {
    
    @Published var present = false
    
    public var alert: AlertInfo?
    
    private var cancel: AnyCancellable?
    private var alerts: [AlertInfo] = []
    
    public private(set) var promisesByAlertId: [String: Future<String, Never>.Promise] = [:]
    
    init() {
        
        $present
        
    }
    
    public func didSelectAction(id actionId: String, in alertId: String) {
        promisesByAlertId[alertId]?(.success(actionId))
        alert = nil
        
        guard !alerts.isEmpty else {
            return
        }
        
        self.alert = alerts.removeFirst()
        DispatchQueue.main.async {
            self.present = true
        }
    }
    
    @discardableResult func show(_ newAlert: AlertInfo) -> AnyPublisher<String, Never> {
        if self.alert == nil {
            self.alert = newAlert
            DispatchQueue.main.async {
                self.present = true
            }
        } else {
            alerts.append(newAlert)
        }
        
        /// el `Future` garantiza que solo se ejecute una vez y luego termine
        /// esto evita que se llame mutiples veces a `withCheckedContinuation`
        let (publisher, resolver) = Future<String, Never>.pending()
        self.promisesByAlertId[newAlert.id] = resolver
        return publisher.eraseToAnyPublisher()
    }
    
    /// Mustra una alerta con la informacion proporcionada
    /// - Parameters:
    ///   - actions: las acciones disponibles
    /// - Returns: Un Future con el id de la accion selecionada
    @discardableResult func show(title: String, message: String, @ArrayBuilder<AlertAction> _ makeActions: () -> [AlertAction]) -> AnyPublisher<String, Never> {
        return show(AlertInfo(title: title, message: message, makeActions))
    }
    
    /// Mustra una alerta con la informacion proporcionada
    /// - Parameters:
    ///   - actions: las acciones disponibles
    /// - Returns: el id de la acion selecionada
    @discardableResult func show(title: String, message: String, actions: [AlertAction]) async -> String {
        await withCheckedContinuation { continuation in
            self.show(title: title, message: message) { () -> [AlertAction] in
                return actions
            }.subscribe(Subscribers.Sink(receiveCompletion: { _ in
                
            }, receiveValue: { selected in
                continuation.resume(returning: selected)
            }))
        }
    }
    
    @discardableResult func show(title: String, message: String, @ArrayBuilder<AlertAction> _ makeActions: () -> [AlertAction]) async -> String {
        await withCheckedContinuation { continuation in
            self.show(title: title, message: message, makeActions)
                .subscribe(Subscribers.Sink(receiveCompletion: { _ in
                    
                }, receiveValue: { selected in
                    continuation.resume(returning: selected)
                }))
        }
    }
    
}


