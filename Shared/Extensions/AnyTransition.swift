//
//  AnyTransition.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 25/03/21.
//

import SwiftUI

extension AnyTransition {
    
    static let topX = AnyTransition.asymmetric(
        insertion: AnyTransition.move(edge: .top).combined(with: .opacity),
        removal:  AnyTransition.move(edge: .top).combined(with: .opacity)
    )
    
    static let bottomX = AnyTransition.asymmetric(
        insertion: .move(edge: .bottom),
        removal: .move(edge: .bottom)
    )
    
    static let equal = AnyTransition.asymmetric(
        insertion: AnyTransition.move(edge: .bottom).combined(with: .opacity),
        removal: AnyTransition.move(edge: .bottom).combined(with: .opacity)
    )
    
    static let leadingX = AnyTransition.asymmetric(
        insertion: AnyTransition.move(edge: .leading).combined(with: .opacity),
        removal:  AnyTransition.move(edge: .trailing).combined(with: .opacity)
    )
    
    static let scaled = AnyTransition.asymmetric(
        insertion: .scale(scale: 0.5, anchor: .bottomLeading),
        removal: .scale(scale: 2)
    )
}
