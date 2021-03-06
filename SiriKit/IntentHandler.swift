//
//  IntentHandler.swift
//  SiriKit
//
//  Created by Carlos Andres Chaguendo Sanchez on 27/05/21.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        switch intent {
        case is BudgetConfigurationIntent:
            return BudgetConfigurationIntentHandler()
        default:
           preconditionFailure()
        }
        
        return self
    }
    
}
