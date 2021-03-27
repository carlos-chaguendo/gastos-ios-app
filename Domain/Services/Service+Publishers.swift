//
//  Service+Publishers.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 18/03/21.
//

import Foundation
import Combine
import UIKit


extension Notification.Name {
    
    static var didAddNewTransaction = Notification.Name(rawValue: "didAddNewTransaction")
    
}


extension Publishers {
    
    static var didAddNewTransaction: AnyPublisher<ExpenseItem, Never> {
        NotificationCenter.default.publisher(for: Notification.Name.didAddNewTransaction)
            .compactMap { $0.object as? ExpenseItem }
            .eraseToAnyPublisher()
    }
    
}
