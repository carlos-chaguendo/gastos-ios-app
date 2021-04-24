//
//  CardViewModifier.swift
//  Gastos
//
//  Created by Carlos Andres Chaguendo Sanchez on 7/04/21.
//

import SwiftUI

struct CardViewModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(ColorSpace.color(light: .white, dark: UIColor.white.withAlphaComponent(0.05)))
            .cornerRadius(20)
            .shadow(color: Color.gray.opacity(0.3), radius: 10)
    }
    
    
}

extension View {
    
    func cardView() -> some View {
        ModifiedContent(content: self, modifier: CardViewModifier())
    }
}

