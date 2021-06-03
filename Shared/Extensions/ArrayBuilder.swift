//
//  ArrayBuilder.swift
//  Gastos
//
//  Created by Carlos Andres Chaguendo Sanchez on 16/03/21.
//

import SwiftUI

@resultBuilder
public struct ArrayBuilder<Element> {

    public static func buildBlock() -> [Element] {
        []
    }
    
    public static func buildBlock(_ components: Element?...) -> [Element] {
        return components.compactMap { $0 }
    }
    
    public static func buildBlock(_ elements: [Element]?...) -> [Element] {
        return elements.compactMap { $0 }.flatMap { $0 }
    }

    public static func buildExpression(_ expression: Element?) -> [Element] {
        [expression].compactMap { $0 }
    }

    public static func buildOptional(_ elements: [Element]?) -> [Element] {
        return elements ?? []
    }

    static func buildEither(first component: [Element]) -> [Element] {
        return component
    }

    static func buildEither( second component: [Element]) -> [Element] {
        return component
    }
}
