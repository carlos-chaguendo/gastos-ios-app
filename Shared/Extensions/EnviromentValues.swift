//
//  EnviromentValues.swift
//  Gastos
//
//  Created by Carlos Andres Chaguendo Sanchez on 27/05/21.
//
import SwiftUI

public extension EnvironmentValues {
    var isPreview: Bool {
        #if DEBUG
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        #else
        return false
        #endif
    }
}
