//
//  PresentLinkView.swift
//  Gastos
//
//  Created by Carlos Andres Chaguendo Sanchez on 1/04/21.
//

import SwiftUI

struct PresentLinkView<Label: View, Destination: View>: View {

    @State var isPresented: Bool = false

    var destination: () -> Destination
    var addNavigation = false
    var label: Label

    init(addNavigation: Bool = false, destination: @escaping @autoclosure () -> Destination, @ViewBuilder label: () -> Label) {
        self.destination = destination
        self.label = label()
        self.addNavigation = addNavigation
    }

    var body: some View {
        Button {
            self.isPresented.toggle()
            UIApplication.shared.windows.forEach { $0.endEditing(true) }
        } label: {
            label
        }.sheet(isPresented: $isPresented) {
            if addNavigation {
                NavigationView {
                    destination()
                }
            } else {
                destination()
            }
        }
    }

}

struct FullScreenCover<Label: View, Destination: View>: View {

    @State var isPresented: Bool = false

    var destination: () -> Destination
    var addNavigation = false
    var label: Label

    init(addNavigation: Bool = false, destination: @escaping @autoclosure () -> Destination, @ViewBuilder label: () -> Label) {
        self.destination = destination
        self.label = label()
        self.addNavigation = addNavigation
    }

    var body: some View {
        Button {
            self.isPresented.toggle()
            UIApplication.shared.windows.forEach { $0.endEditing(true) }
        } label: {
            label
        }.fullScreenCover(isPresented: $isPresented) {

            if addNavigation {
                NavigationView {
                    destination()
                }
            } else {
                destination()
            }
        }
    }

}
