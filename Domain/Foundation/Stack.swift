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
        return array[index]
    }
    
    init(arrayLiteral elements: Element...) {
        self.max = elements.count
        self.array = elements
    }

    mutating func left(_ e: Element) {
        array.remove(at: array.count - 1)
        array.insert(e, at: 0)
    }
    
    mutating func right(_ e: Element) {
        array.remove(at: 0)
        array.append(e)
    }
    
    var isEmpty: Bool { array.isEmpty }
    
    var last: Element { array.last! }
    var first: Element { array.first! }
    
}
