//
//  ExpenseItemView.swift
//  CaptuOCR
//
//  Created by Carlos Andres Chaguendo Sanchez on 10/03/21.
//

import SwiftUI

struct ExpenseItemView: View {

    let model: ExpenseItem

    var displayCategory: Bool = true

    var body: some View {

        HStack {
            VStack(alignment: .leading, spacing: 0) {

                if displayCategory {
                    Text(model.category?.name.trimed ?? "N/A")
                        .foregroundColor(Colors.title)
                }

                if !model.title.trimed.isEmpty {
                    Text(model.title.trimed)
                        .if(displayCategory) { text in
                            text.font(.system(size: 14)).foregroundColor(Colors.subtitle)
                        } else: { text in
                            text.foregroundColor(Colors.title)
                        }
                }

                FlexibleView(data: model.tags.toArray()) { item in
                    Text(verbatim: item.name)
                        .font(.caption2)
                        // .fontWeight(.medium)
                        .padding(3)
                        .foregroundColor(Colors.Form.value)
                        .background(
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(Colors.Tags.background3))
                        ).padding(.vertical, 3)
                }

                Spacer().frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, idealHeight: 0, maxHeight: 0)
            }

            Spacer()
            Text(NumberFormatter.currency.string(from: NSNumber(value: model.value)) ?? "")
                .fontWeight(.regular)
                .foregroundColor(Colors.title)
        }
        .padding(.vertical, 1)
    }
}

struct ExpenseItemView_Previews: PreviewProvider {

    static var previews: some View {
        VStack {

            ExpenseItemView(
                model: .init {
                    $0.title = "Tamal"
                    $0.value = 3500
                    $0.category = .init {
                        $0.name = "Comida"
                    }
                    $0.tags.append(.init {
                        $0.name = "Marisol"
                    })
                    $0.tags.append(.init {
                        $0.name = "Popayan"
                    })
                }
            )
            .preferredColorScheme(.dark)

            ExpenseItemView(
                model: .init {
                    $0.title = "Jack Jhonas"
                    $0.value = 3500
                    $0.category = .init {
                        $0.name = "Comida "
                    }
                    $0.tags.append(.init {
                        $0.name = "Marisol "
                    })
                    $0.tags.append(.init {
                        $0.name = "Popayan "
                    })
                }
            )
            .preferredColorScheme(.light)

            ExpenseItemView(
                model: .init {
                    $0.title = " gafas "
                    $0.value = 3500
                    $0.category = .init {
                        $0.name = "Varios"
                    }

                }
            )
            .preferredColorScheme(.light)

            ExpenseItemView(
                model: .init {
                    $0.value = 3500
                    $0.category = .init {
                        $0.name = "Varios "
                    }

                }
            )
            .preferredColorScheme(.light)

        }

        .padding()
        // .previewLayout(PreviewLayout.fixed(width: 350, height: 100))

    }
}
