//
//  Promise.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 15/04/21.
//

import Foundation
import Combine

func Promise<Output>( block: @escaping () -> Output) -> AnyPublisher<Output, Never> {
    
    #if DEBUG
    return Just(block()).eraseToAnyPublisher()
    #else
    return Deferred {
        Future<Output, Never> { seal in
            DispatchQueue.main.async {
                seal(Result.success(block()))
            }
        }
    }.eraseToAnyPublisher()
    #endif
    
}


extension Publisher {
    
    func retainValue<T, P>(maxPublishers: Subscribers.Demand = .unlimited, _ transform: @escaping (Self.Output) -> P)
    -> Publishers.Zip<Self, Publishers.FlatMap<P, Self>>
    where T == P.Output, P : Publisher, Self.Failure == P.Failure {
        
        return Publishers.Zip(self, self.flatMap(transform))
        
    }
    
    func asVoid() -> Publishers.Map<Self, Void> {
        self.map { _ in () }
    }
    
}

