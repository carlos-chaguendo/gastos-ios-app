//
//  CircularChart.swift
//  Gastos
//
//  Created by Carlos Andres Chaguendo Sanchez on 28/04/21.
//

import SwiftUI

struct CircularChart: View {
    
    struct Entry {
        let color: Color
        let value: CGFloat
        var previous: CGFloat = 0.0
        
    }
    
    var percents: [Entry] = []
    @State var setPercents: Bool = false
    @State var setPercents2: Bool = false
    
    var animatable: Bool = true
    var lineWidth: CGFloat = 8
    var lineSpacing: CGFloat = 0.04
    var lineBackGround: Color = Color.secondary
    
    init(animatable: Bool = true, lineWidth: CGFloat = 8, lineSpacing: CGFloat = 0.04, lineBackGround: Color = .secondary, _ percents: [Entry]) {
        self.setPercents = animatable
        self.animatable = animatable
        self.lineWidth = lineWidth
        self.lineSpacing = lineSpacing
        self.lineBackGround = lineBackGround
        
        var sum: CGFloat = 0.0
        for i in 0..<percents.count {
            var current = percents[i]
            current.previous = sum
            self.percents.append(current)
            
            sum += CGFloat(current.value)
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Circle()
                .stroke(lineWidth: lineWidth)
                .opacity(0.3)
                .foregroundColor(lineBackGround.opacity(0.4))
            
            ForEach(0..<percents.count, id: \.self) { i in
            
                
                let entry = percents[i]
                //let previous = CGFloat(percents[safe: i - 1 ]?.value ?? 0)

                let includeAnimation = animatable ? setPercents : true
                
                Circle()
                    .trim(from: includeAnimation ? entry.previous : 0, to:  includeAnimation ? entry.value + entry.previous - lineSpacing : 0)
                    //.fill()
                    .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                    .foregroundColor(entry.color.opacity(0.6))
                    .onAppear() {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(Animation.easeInOut(duration: 1)) {
                                self.setPercents = true
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(Animation.easeInOut(duration: 1)) {
                                    self.setPercents2 = true
                                }
                            }
                            
                        }
                    }//.rotationEffect(Angle.degrees(-90))
 
            }
            
        }
    }
    
}

struct CircularChart_Previews: PreviewProvider {
    static var previews: some View {
       ZStack {
            CircularChart([
                .init(color: .yellow, value: 0.25),
                .init(color: .yellow, value: 0.25),
                .init(color: .yellow, value: 0.2),
                .init(color: .yellow, value: 0.2),
                .init(color: .yellow, value: 0.1)
            ]).padding().padding()
            
            CircularChart([
                .init(color: .red, value: 0.333),
                .init(color: .red, value: 0.333),
                .init(color: .red, value: 0.333),
            ])
            
            CircularChart([
                .init(color: .green, value: 0.3),
                .init(color: .green, value: 0.3),
                .init(color: .green, value: 0.3),
            ]).padding()
        }.padding()
        
        .preferredColorScheme(.dark)
    }
}
