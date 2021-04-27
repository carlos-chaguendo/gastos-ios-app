//
//  NotificationsCategory.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 23/04/21.
//

import Foundation
import UserNotifications

enum NotificationsCategory: String, CaseIterable {

    case medicationsToDispnes = "TO_DISPENSE"
    case dailyReminder = "DailyReminder"

    private func category() -> UNNotificationCategory {
        return UNNotificationCategory(
            identifier: rawValue,
            actions: [
//                Action.decline.action(),
//                Action.accept.action(),
 //               Action.view.action()
            ],
            intentIdentifiers: [],
            options: []
        )
    }

    public static func all() -> Set<UNNotificationCategory> {
        return Set(NotificationsCategory.allCases.map { $0.category() })
    }

}

extension NotificationsCategory {

/// Todas las acciones deben gener un identificador unico incluso si estan en diferentes categorias
    enum Action: String {

        case decline = "DECLINE"
        case accept = "ACCEPT"
        case view = "VIEW"

        public func action() -> UNNotificationAction {
            switch self {
            case .decline:
                return UNNotificationAction(identifier: rawValue, title: "Decline", options: .destructive)

            case .accept:
                return UNNotificationAction(identifier: rawValue, title: "Accept", options: .destructive)

            case .view:
                return UNNotificationAction(identifier: rawValue, title: "View", options: [.foreground, .authenticationRequired])

            }
        }
    }

}
