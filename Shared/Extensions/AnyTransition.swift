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
}
