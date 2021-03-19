//
//  NumberFormatter.swift
//  Gastos
//
//  Created by Carlos Andres Chaguendo Sanchez on 12/03/21.
//

import Foundation
import SwiftUI

extension NumberFormatter {
    
    public static var currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
}
