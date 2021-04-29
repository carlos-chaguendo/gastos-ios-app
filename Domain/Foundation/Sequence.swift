//
//  Sequence.swift
//  Gastos
//
//  Created by Carlos Andres Chaguendo Sanchez on 24/04/21.
//

import Foundation

extension Sequence where Iterator.Element: Identifiable {

    /// Crea una versión libre de duplicados de una Array, usando comparaciones de igualdad, en la que sólo se mantiene la primera ocurrencia de cada elemento.
    /// El orden de los valores de los resultados se determina por el orden en que ocurren en el array.
    public var uniq: [Iterator.Element] {
        return self.uniq(by: { element -> Iterator.Element.ID in
            return element.id
        })
    }

}

extension Sequence {

    /// Este método es como `.uniq` excepto que acepta una funcion que se invoca para cada elemento en el array para generar el criterio por el cual se calcula la unicidad.
    /// El orden de los valores de los resultados se determina por el orden en que ocurren en el array. La iteración se invoca con un argumento:
    /// - Parameters:
    ///   - getIdentifier: La funcion invocada por elemento
    /// - Returns: Devuelve el nuevo array libre de duplicados.
    public func uniq<Id: Hashable >(by getIdentifier: (Iterator.Element) -> Id) -> [Iterator.Element] {
        var ids = Set<Id>()
        return self.reduce([]) { uniqueElements, element in
            if ids.insert(getIdentifier(element)).inserted {
                return uniqueElements + CollectionOfOne(element)
            }
            return uniqueElements
        }
    }

    public func groupBy<U: Hashable>(_ keyFunc: (Iterator.Element) -> U) -> [U: [Iterator.Element]] {
        var dict: [U: [Iterator.Element]] = [:]
        for el in self {
            let key = keyFunc(el)
            dict[key, default: []].append(el)
        }
        return dict
    }

    public func countBy<U: Hashable>(_ keyFunc: (Iterator.Element) -> U) -> [U: Int] {
        var dict: [U: Int] = [:]
        for el in self {
            let key = keyFunc(el)
            dict[key, default: 0] += 1
        }
        return dict
    }

}

extension Sequence where Iterator.Element: Hashable {

    /// Crea una versión libre de duplicados de una Array, usando comparaciones de igualdad, en la que sólo se mantiene la primera ocurrencia de cada elemento.
    /// El orden de los valores de los resultados se determina por el orden en que ocurren en el array.
    public var uniq: [Iterator.Element] {
        return self.uniq(by: { (element) -> Iterator.Element in
            return element
        })
    }

}

extension Collection where Index == Int {

    /// nil si el indice es menor a 0 o mayor a tamanio del array
    public subscript(safe index: Int) -> Element? {
        return index >= 0 && index < count ? self[index] : nil
    }
}
