//
//  ArrayBuilder.swift
//  Gastos
//
//  Created by Carlos Andres Chaguendo Sanchez on 16/03/21.
//

import SwiftUI

@_functionBuilder
public struct ArrayBuilder<Element> {

    public static func buildBlock(_ components: Element?...) -> [Element] {
        return components.compactMap { $0 }
    }
}
