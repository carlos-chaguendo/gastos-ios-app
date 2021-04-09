//
//  Colors.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 10/03/21.
//

import SwiftUI
#if os(macOS)
import AppKit
typealias ColorSpace = NSColor

#else
import UIKit
typealias ColorSpace = UIColor
#endif


extension ColorSpace {
    
    static func color(light: UIColor, dark: UIColor) -> UIColor {
        UIColor { trait in
            if trait.userInterfaceStyle == .light {
                return light
            }
            
            return dark
        }
    }
}


enum Colors {
    
    public static let primary: ColorSpace = .color(light: #colorLiteral(red: 0.262745098, green: 0.462745098, blue: 1, alpha: 0.7921539494), dark: #colorLiteral(red: 0.1450980392, green: 0.4901960784, blue: 0.5058823529, alpha: 1))
    public static let background: ColorSpace = .color(light: .white, dark: #colorLiteral(red: 0, green: 0.1479207078, blue: 0.1882454439, alpha: 1))
    
    public static let groupedBackground: ColorSpace = .color(light: .systemGroupedBackground, dark: background.withAlphaComponent(0.6))
    
    public static let label: ColorSpace = .color(light: .label, dark: #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1))
    public static let primaryII: ColorSpace = .color(light: #colorLiteral(red: 0.262745098, green: 0.462745098, blue: 1, alpha: 0.7921539494), dark: #colorLiteral(red: 0.2431372549, green: 0.462745098, blue: 0.7176470588, alpha: 1))
    public static let backgroundII: ColorSpace = .color(light: .white, dark: #colorLiteral(red: 0.1098039216, green: 0.1529411765, blue: 0.2156862745, alpha: 1))
    
    public static let title: ColorSpace = label//UIColor.color(light:#colorLiteral(red: 0.09019607843, green: 0.168627451, blue: 0.3019607843, alpha: 1), dark: #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1))
    public static let subtitle: ColorSpace = #colorLiteral(red: 0.4196078431, green: 0.4666666667, blue: 0.5490196078, alpha: 1)
    
    
    struct Form {
        public static let label: ColorSpace =  .color(light: ColorSpace.secondaryLabel,  dark: ColorSpace.secondaryLabel)
        public static let value: ColorSpace = .color(light: #colorLiteral(red: 0.09411764706, green: 0.1725490196, blue: 0.2941176471, alpha: 1), dark: .white)
    }
    
    
    public static let shadown: ColorSpace = ColorSpace.color(light: #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1), dark: #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)).withAlphaComponent(0.2)
    
}


extension View {
    
    func background(_ color: ColorSpace) -> some View {
        self.background(Color(color))
    }
    
    func foregroundColor(_ color: ColorSpace) -> some View {
        self.foregroundColor(Color(color))
    }
    
    func accentColor(_ color: ColorSpace) -> some View {
        self.accentColor(Color(color))
    }
    
}


extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
