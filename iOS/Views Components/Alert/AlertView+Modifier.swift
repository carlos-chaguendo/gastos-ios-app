//
//  AlertViewModifier.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 9/02/22.
//

import SwiftUI

struct AlertViewSupport: ViewModifier {
    
    @StateObject var alertController:AlertViewController
    
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            let ctrl = $alertController
            content
                .background(Text(ctrl.present.wrappedValue ? "Si": "No"))
                .alert("Capija", isPresented:  ctrl.present, presenting: ctrl.alert.wrappedValue) { info in
                    ForEach(info.actions) { action in
                        Button(action.id, action: action.action)
                    }
                } message: { info in
                    Text(info.message)
                }
        } else {
            content
        }
    }
    
}

extension View {
    
    func alert(from alertViewController: AlertViewController) -> some View {
        self.modifier(AlertViewSupport(alertController: alertViewController))
    }
    
}
