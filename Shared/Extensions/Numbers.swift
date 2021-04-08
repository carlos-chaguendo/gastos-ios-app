//
//  Numbers.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 7/04/21.
//

import Foundation
import CoreGraphics

extension CGFloat {
    
    public func map(from: Range<CGFloat>, to: Range<CGFloat>) -> CGFloat {
        let x = self
        
        let inmin = from.lowerBound
        let inmax = from.upperBound
        
        let outmin = to.lowerBound
        let outmax = to.upperBound
        
        let sup = (x - inmin) * (outmax - outmin)
        let sub = (inmax - inmin) + outmin
        return sup / sub
    }
    
}
