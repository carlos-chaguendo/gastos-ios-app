//
//  LinesGraphView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 8/04/21.
//

import SwiftUI

extension Chart {
    
    class DataSet: Identifiable {
        let points: [CGPoint]
        let color: Color
        
        init(points: [CGPoint], color: Color) {
            self.points = points
            self.color = color
        }
    }
    
    struct Lines: View {
        
        let datasource: [DataSet]
        
        var body: some View {
            VStack(spacing: 4) {
                ZStack {
                    ForEach(datasource) { item in
                        Chart.ColumnsShape(points: item.points)
                            .stroke(item.color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                            .scaleEffect(CGSize(width: 0.95, height: 1))
                    }
                }

                Chart.LinePointShape(count: datasource.map { $0.points.count }.max() ?? 3 )
                    .frame(height: 1)
                    .foregroundColor(.tertiaryLabel)
                    .scaleEffect(CGSize(width: 0.95, height: 1))
            }
            
        }

    }
}


//
struct LineGraph_Previews: PreviewProvider {
    
    static let points: [CGPoint] = [
        CGPoint(x: 0, y: 100),
        CGPoint(x: 0, y: 20),
        CGPoint(x: 0, y: 40),
        CGPoint(x: 0, y: 60),
        CGPoint(x: 0, y:  50),
        CGPoint(x: 0, y: 300)
    ]
    
    static var previews: some View {
        Group {
            Chart.Lines(datasource: [
                .init(points: points.dropLast().dropLast(), color: Color(UIColor.systemGroupedBackground)),
                .init(points: points.reversed(), color: .green),
            ])
            .cardView()
            .padding()
            .previewLayout(PreviewLayout.fixed(width: 220 , height: 220))
           
            Chart.Lines(datasource: [
                .init(points: points.reversed(), color: Color(UIColor.systemGroupedBackground)),
                .init(points: points, color: .green),
            ])
            .cardView()
            .padding()
            .previewLayout(PreviewLayout.fixed(width: 120 , height: 120))
            .preferredColorScheme(.dark)
            
        }
        
    }
}
