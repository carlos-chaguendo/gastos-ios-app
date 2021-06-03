//
//  KeyboardAdaptive.swift
//  Gastos
//
//  Created by Carlos Andres Chaguendo Sanchez on 11/03/21.
//

import SwiftUI
import Combine

/// Note that the `KeyboardAdaptive` modifier wraps your view in a `GeometryReader`,
/// which attempts to fill all the available space, potentially increasing content view size.
/// https://www.vadimbulavin.com/how-to-move-swiftui-view-when-keyboard-covers-text-field/
struct KeyboardAdaptive: ViewModifier {
    @State private var bottomPadding: CGFloat = 0
    
    func body(content: Content) -> some View {
        #if os(macOS)
        return content.padding(.bottom, self.bottomPadding)
        #else
        return GeometryReader { geometry in
            content
                .background(Color.red)
                .padding(.bottom, self.bottomPadding)
                .background(Color.yellow)
                .onReceive(Publishers.keyboardHeight) { keyboardHeight in
                    let keyboardTop = geometry.frame(in: .global).height - keyboardHeight
                    let focusedTextInputBottom = UIResponder.currentFirstResponder?.globalFrame?.maxY ?? 0
                    self.bottomPadding = max(0, focusedTextInputBottom - keyboardTop - geometry.safeAreaInsets.bottom)
                }.animation(.easeOut(duration: 0.16))
                .overlay(Text(" \(self.bottomPadding)"))
        }
        #endif
    }
}

extension View {
    func keyboardAdaptive() -> some View {
        ModifiedContent(content: self, modifier: KeyboardAdaptive())
    }
}
