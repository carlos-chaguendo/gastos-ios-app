//
//  DayListView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 10/03/21.
//

import SwiftUI

struct DayListView: View {

    var items: [ExpenseItem] = []

    var body: some View {
        List(items) { item in
            ExpenseItemView(model: item)
        }.listStyle(InsetListStyle())
    }
}

struct DayListView_Previews: PreviewProvider {
    static var previews: some View {

            DayListView(items: [
                ExpenseItem(title: "Tamal", value: 3500),
                ExpenseItem(title: "Perfume", value: 7800, tags: ["Varios"]),
                ExpenseItem(title: "Desayuno", value: 8900, tags: ["Comida", "Marisol"])
            ]).previewLayout(PreviewLayout.fixed(width: 350, height: 200))

    }
}
