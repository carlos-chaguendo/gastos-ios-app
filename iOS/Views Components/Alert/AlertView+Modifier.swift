//
//  AlertViewModifier.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 9/02/22.
//

import SwiftUI

struct AlertViewSupport: ViewModifier {
    
    @ObservedObject var ctrl: AlertViewController
    
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            let _ = Self._printChanges()
            let title = $ctrl.alert.wrappedValue?.title ?? ""
            content.alert(title, isPresented: $ctrl.present, presenting: ctrl.alert) { alert in
                ForEach(alert.actions) { action in
                    
                    Button(action.id) {
                        ctrl.didSelectAction(id: action.id, in: alert.id)
                        action.action()
                    }
                }
            } message: { alert in
                Text(alert.message)
            }
        } else {
            content
        }
    }
    
}

extension View {
    
    func alert(from alertViewController: AlertViewController) -> some View {
        self.modifier(AlertViewSupport(ctrl: alertViewController))
    }
    
}
