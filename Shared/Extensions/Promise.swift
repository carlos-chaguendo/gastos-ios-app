//
//  Promise.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 15/04/21.
//

import Foundation
import Combine

func Promise<Output>( block: @escaping () -> Output) -> AnyPublisher<Output, Never> {

//    #if !DEBUG
//    return Just(block()).eraseToAnyPublisher()
//    #else
    return
        Deferred {
        Future<Output, Never> { seal in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 ) {
                seal(Result.success(block()))
            }
        }
    }
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
//    #endif

}

func fistly<P: Publisher>(block: () -> P) -> P {
    block()
}

extension Publisher {

    func retainValue<T, P>(maxPublishers: Subscribers.Demand = .unlimited, _ transform: @escaping (Self.Output) -> P)
    -> Publishers.Zip<Self, Publishers.FlatMap<P, Self>>
    where T == P.Output, P: Publisher, Self.Failure == P.Failure {

        return Publishers.Zip(self, self.flatMap(transform))

    }

    func asVoid() -> Publishers.Map<Self, Void> {
        self.map { _ in () }
    }

}


extension Future {
    /**
      Contructor en futuros pendientes que no se resolveran inmediatamanete
     
        Una costruccion mas rapida
     
        ```
        let (publisher, resolver) =  Future<String, never>.pending()
        return publisher
        ```
    */
    class func pending() -> (Future, Future.Promise) {
        var promise: Future.Promise!
        let publisher = Future { promise = $0 }
        return (publisher, promise)
    }
    
}

