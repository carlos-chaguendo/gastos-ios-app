//
//  SegmentedView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 29/04/21.
//

import SwiftUI

struct SegmentedView<SelectionValue: Hashable, Content: View>: View {

    @Binding var selected: SelectionValue
    var values: [SelectionValue]

    var generator: (SelectionValue) -> Content

    init(_ values: [SelectionValue], selected: Binding<SelectionValue>, make: @escaping (SelectionValue) -> Content) {
        self._selected = selected
        self.values = values
        self.generator = make
    }

    var body: some View {
        ZStack(alignment: .bottom) {

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                ForEach(0..<values.count) { i in

                    Button {
                        
                            self.selected = values[i]

                    } label: {
                        VStack {
                            generator(values[i])
                               
                                .if(selected == values[i]) { text in
                                    text.foregroundColor(Colors.primary)
                                }
                                .if(selected != values[i]) { text in
                                    text.foregroundColor(Color.secondary)
                                }

                            if selected == values[i] {
                                Color(Colors.primary)
                                    .frame(height: 2)

                            }
                        }
                   }
                   .frame(minWidth: 0, maxWidth: .infinity)

                }
            }

            Color.secondary.opacity(0.3)
                .frame(height: 2)

        }
    }
}
//
struct SegmentedView_Previews: PreviewProvider {

    @State static var selected = "2"
    @State  static var values = ["1", "2", "3"]

    @State static var selected2 = 0.0

    static var previews: some View {

        VStack {

            SegmentedView(values, selected: $selected) { e in
                Text(e)
                    .background(.green)

            }

            Slider(value: $selected2, in: 0...1)

        }.padding()
    }
}
