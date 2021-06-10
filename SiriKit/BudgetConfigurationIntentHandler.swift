//
//  BudgetConfigurationIntentHandler.swift
//  SiriKit
//
//  Created by Carlos Andres Chaguendo Sanchez on 27/05/21.
//

import Intents

class BudgetConfigurationIntentHandler: NSObject, BudgetConfigurationIntentHandling {
 
    func resolveDisplayAvalilable(for intent: BudgetConfigurationIntent, with completion: @escaping (INBooleanResolutionResult) -> Void) {
        completion(.success(with: (intent.displayAvalilable?.boolValue ?? false)))
    }
    
}
