//
//  TagsChartView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 15/04/21.
//

import SwiftUI

struct TagsChartView: View {

    @State var tags: [Tag] = []

    var body: some View {
        VStack(alignment: .leading) {
            Text("Tags")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(Colors.title)

            FlexibleView(data: tags) { item in
                Text(item.name)
                    .font(.callout)
                    .padding(.horizontal)
                    .frame(height: 34)
                    .background(Colors.Tags.background)
                    .foregroundColor(Colors.primary)
                    .cornerRadius(3.0)
                    .padding(2)
            }
        }.onAppear {
            self.tags = Service.getAll(Tag.self).sorted { $0.name > $1.name }
        }
    }
}

struct TagsChartView_Previews: PreviewProvider {
    static var previews: some View {
        TagsChartView()
    }
}
