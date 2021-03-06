//
//  KeyboardHeightPublisher.swift
//  Gastos
//
//  Created by Carlos Andres Chaguendo Sanchez on 11/03/21.
//

import Combine
#if !os(macOS)
import UIKit

extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }

        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }

        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
    
    static var textFieldBeginEditing: AnyPublisher<UITextField, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)
            .map { $0.object as! UITextField }
            .eraseToAnyPublisher()
    }
}

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}
#endif
