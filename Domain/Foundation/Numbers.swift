//
//  Numbers.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 7/04/21.
//

import Foundation
import CoreGraphics

extension Numeric where Self: FloatingPoint {

    public func map(from: Range<Self>, to: Range<Self>) -> Self {

        let inmin = from.lowerBound
        let inmax = from.upperBound

        let outmin = to.lowerBound
        let outmax = to.upperBound

        let sup = (self - inmin) * (outmax - outmin)
        let sub = (inmax - inmin) + outmin
        return sup/sub
    }

}

extension FloatingPoint {
    /// Rounds the double to decimal places value
    public func rounded(toPlaces places: Int) -> Self {
        let divisor = Self(Int(pow(10.0, Double(places))))
        return (self * divisor).rounded() / divisor
    }

}

extension Double {

    public var cleanValue: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }

}

extension CGFloat {

    public var cleanValue: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : self.description
    }

}
