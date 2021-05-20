//
//  CircularChart.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 28/04/21.
//

import SwiftUI

/// https://exyte.com/blog/swiftui-tutorial-replicating-activity-application
struct RingChart: View {
    
    let color: Color
    let percent: Double
    
    @State private var currentPercent: Double = 0.0
    
    var body: some View {
        ZStack(alignment: .top) {
            Circle()
                .stroke(lineWidth: 15)
                .opacity(0.3)
                .foregroundColor(color.opacity(0.3))
            
            Circle()
                .trim(from: 0, to: CGFloat(currentPercent))
                // .fill(LinearGradient(gradient: Gradient(colors: [color.opacity(0.5), .white]), startPoint: .bottom, endPoint: .top))
                .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .miter))
                .foregroundColor(color.opacity(0.8))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation(Animation.easeInOut(duration: 1)) {
                            self.currentPercent = self.percent
                        }
                    }
                }.rotationEffect(Angle.degrees(-90))
            
            Text("\((percent * 100).cleanValue) %")
                .font(.caption2)
                .fontWeight(.bold)
                .offset(x: 8, y: -6)
                .foregroundColor(color.uicolor.shadeColor(factor: 0.8))
            
        }
    }
}

struct RingChart_Previews: PreviewProvider {
    
    static let points: [CGPoint] = [
        CGPoint(x: 0, y: 100),
        CGPoint(x: 0, y: 20),
        CGPoint(x: 0, y: 40),
        CGPoint(x: 0, y: 60),
        CGPoint(x: 0, y: 50),
        CGPoint(x: 0, y: 300)
    ]
    
    static var previews: some View {
  
        VStack {
            ZStack {
                ForEach(1...4, id: \.self) { i in
                    let w =  CGFloat(32 + (32 * i))
                    let percent = Double(i)/10.0
        
                    RingChart(color: Color(UIColor.random), percent: percent)
                        .frame(width: w, height: w)
                }
            }
            // .rotationEffect(Angle.degrees(-90))
            // .cardView()
        
            Chart.Lines(datasource: [
                .init(points: points.dropLast().dropLast(), color: Color(UIColor.systemGroupedBackground)),
                .init(points: points.reversed(), color: .green)
            ])

            // .cardView()
            
        }.padding()

    }
}
