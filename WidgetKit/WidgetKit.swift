//
//  WidgetKit.swift
//  WidgetKit
//
//  Created by Carlos Andres Chaguendo Sanchez on 24/04/21.
//

import WidgetKit
import SwiftUI
import Combine

/// # Supporting Multiple Widgets #
/// Es posible configurar multiples widgets `WidgetBundle`
@main
struct WidgetsBundle: WidgetBundle {

    @WidgetBundleBuilder
    var body: some Widget {
        WalletWidget()
        CategoryWidget()
        RingWidget()
        ExpensStackChartWidget()
    }

}
