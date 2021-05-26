//
//  StackChart.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 15/04/21.
//

import SwiftUI

struct StackChart<Group: Entity & ExpensePropertyWithValue>: View {
    
    var total: Double = 1
    let categories: [Group]
    
    var body: some View {
        GeometryReader { reader in
            HStack(spacing: 0.5) {
                if categories.isEmpty {
                    Spacer()
                } else {
                    ForEach(categories, id: \.self) { category in
                        let percent = ((category.value * 100)/self.total/100)
                        
                        Color(UIColor.from(hex: UInt32(category.color)))
                            .frame(width: reader.size.width * CGFloat(percent))
                        
                    }
                }
            }
        }
        .background(Colors.groupedBackground)
        .frame(height: 16)
        .cornerRadius(8.0)
    }
    
}


struct LinearProgressView<Value: BinaryFloatingPoint>: View {
    
    var tint: Color = Color.primary
    var value: Value
    var total: Value
    
    var body: some View {
        GeometryReader { reader in
            
            ZStack(alignment: .leading) {
                tint.opacity(0.2)
                
                let percent = ((value * 100)/total/100)
                tint.frame(width: reader.size.width * CGFloat(percent))
                
            }.frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity)
            
        }
        .background(Colors.groupedBackground)
        .frame(height: 4)
        .cornerRadius(2.0)
    }
}


struct StackChart_Previews: PreviewProvider {
    static var previews: some View {
        
        VStack {
            
            LinearProgressView(tint: .red, value: 350.0/2, total: 350.0)
            
            StackChart<Wallet>(categories: [
                .init {
                    $0.name = "Hola"
                    $0.value = 0.5
                },
                
                .init {
                    $0.name = "Beats"
                    $0.value = 0.25
                    $0.color = 0xCC0000
                }
            ])
            
        }.padding()
    }
}
