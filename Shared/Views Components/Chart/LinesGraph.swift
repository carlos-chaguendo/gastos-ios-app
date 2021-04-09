//
//  LinesGraphView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 8/04/21.
//

import SwiftUI


enum Chart {
    
}

extension Shape {
    
    func scaled(to scale: CGSize) -> some Shape {
        ScaledShape(shape: self, scale: scale)
    }
}


extension Chart {
    
    struct LinePointShape: Shape {
        
        let count: Int
        
        func path(in rect: CGRect) -> Path {
            Path { path in
                let size = CGSize(width: 2, height: 2)
                let x = (rect.width)/CGFloat(max(1, count - 1))
                
                for i in 0..<Int(count){
                    path.addEllipse(in: CGRect(origin: CGPoint(x: CGFloat(i) * x, y: rect.maxY - size.height), size: size))
                }
            }
        }
    }
    
    struct LinesShape: Shape {
        
        let points: [CGPoint]
        
        func path(in rect: CGRect) -> Path {
            Path { path in
                //let size = CGSize(width: 1.5, height: 1.5)
                let x = (rect.width )/CGFloat(points.count - 1)
                let max = Swift.max(points.map{ $0.y }.max() ?? 0, rect.maxY)
                
                path.move(to: CGPoint(x: 0, y: rect.maxY))
                for p in points.enumerated() {
                    let y = rect.maxY - p.element.y.map(from: 0..<max, to: 0..<rect.maxY)
                    let l = CGPoint(x: CGFloat(p.offset) * x, y: y)
                    
                    
                    if p.offset > 0 {
                        path.addLine(to: l)
                    }
                    path.move(to: l)
                }
                path.closeSubpath()
            }
        }
    }
    
    struct ColumnsShape: Shape {
        
        let points: [CGPoint]
        
        func path(in rect: CGRect) -> Path {
            Path { path in
                //let size = CGSize(width: 1.5, height: 1.5)
                let x = (rect.width )/CGFloat(points.count - 1)
                let max = Swift.max(points.map{ $0.y }.max() ?? 0, rect.maxY)
                
                path.move(to: CGPoint(x: 0, y: rect.maxY))
                for p in points.enumerated() {
                    let y = rect.maxY - p.element.y.map(from: 0..<max, to: 0..<rect.maxY-1)
                    let l = CGPoint(x: CGFloat(p.offset) * x, y: y)
                    
                    let h = rect.maxY - y
                    
                    if h == 0 {
                        continue
                    }
                    
                    path.move(to: l)
                    path.addRoundedRect (in: CGRect(origin: l, size: CGSize(width: 1, height: h)), cornerSize: CGSize(width: 1, height: 1))
                    path.closeSubpath()
                }
                path.closeSubpath()
            }
        }
        
    }
    
}

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
