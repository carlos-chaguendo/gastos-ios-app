//
//  ExpenseItemView.swift
//  CaptuOCR
//
//  Created by Carlos Andres Chaguendo Sanchez on 10/03/21.
//

import SwiftUI

struct ExpenseItemView: View {
    
    
    let model: ExpenseItem
    
    var body: some View {
        VStack {
            HStack {
                Text(model.title)
             
                    .font(.system(size: 15))
                    .fontWeight(.semibold)
                    .foregroundColor(Colors.title)
                
                Spacer()
                Text(NumberFormatter.currency.string(from: NSNumber(value: model.value)) ?? "")
                    .font(Font.menlo(size: 15))
                    .fontWeight(.medium)
                    .foregroundColor(Colors.title)
            }

            FlexibleView(data: model.tags) { item in
                Text(verbatim: item)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .padding(3)
                    .foregroundColor(Colors.subtitle)
                    .background(
                       RoundedRectangle(cornerRadius: 4)
                         .fill(Color.gray.opacity(0.2))
                      )
            }.padding(.top, -6)
            
            
        }
    }
}

struct ExpenseItemView_Previews: PreviewProvider {
    

    static var previews: some View {
        Group {
            ExpenseItemView(model: ExpenseItem(title: "Tamales", value: 3500, tags: ["Desayuno", "Comida", "Marisol"]))
                .preferredColorScheme(.dark)
            
            ExpenseItemView(model: ExpenseItem(title: "Tamales", value: 3500, tags: ["Desayuno", "Comida", "Marisol"]))
                .preferredColorScheme(.light)

        }
       
        .padding()
        .previewLayout(PreviewLayout.fixed(width: 350, height: 60))
   
    }
}
