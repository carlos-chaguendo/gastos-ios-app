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
            .background(Colors.Card.background)
            .cornerRadius(20)
            .shadow(color: Color(Colors.Card.shadown), radius: 10)
    }
    
    
}

extension View {
    
    func cardView() -> some View {
        ModifiedContent(content: self, modifier: CardViewModifier())
    }
}

