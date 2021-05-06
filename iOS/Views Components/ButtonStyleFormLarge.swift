//
//  ButtonStyleFormLarge.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 23/04/21.
//

import SwiftUI

struct ButtonStyleFormLarge: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(12)
            .background(Colors.primary)
            .foregroundColor(.white)
            .cornerRadius(4.0)
    }
}
