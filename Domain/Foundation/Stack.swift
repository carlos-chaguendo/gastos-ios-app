//
//  Stack.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 7/04/21.
//

import Foundation

struct Stack<Element>: ExpressibleByArrayLiteral {

    typealias ArrayLiteralElement = Element

    let max: Int

    private var array: [Element] = []

    subscript(safe index: Int) -> Element? {
        return index >= 0 && index < array.count ? array[index] : nil
    }

    subscript(_ index: Int) -> Element {
        get {
            array[index]
        }
        set(newValue) {
            array[index] = newValue
        }
    }

    init(arrayLiteral elements: Element...) {
        self.max = elements.count
        self.array = elements
    }

    mutating func left(_ element: Element) {
        array.remove(at: array.count - 1)
        array.insert(element, at: 0)
    }

    mutating func right(_ element: Element) {
        array.remove(at: 0)
        array.append(element)
    }

    var isEmpty: Bool { array.isEmpty }

    var last: Element { array.last! }
    var first: Element { array.first! }

}
