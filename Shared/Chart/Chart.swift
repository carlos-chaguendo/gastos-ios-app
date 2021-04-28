//
//  Chart.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 15/04/21.
//

import SwiftUI

//https://github.com/AppPear/ChartView
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

                for i in 0..<Int(count) {
                    path.addEllipse(in: CGRect(origin: CGPoint(x: CGFloat(i) * x, y: rect.maxY - size.height), size: size))
                }
            }
        }
    }

    struct LinesShape: Shape {

        let points: [CGPoint]

        func path(in rect: CGRect) -> Path {
            Path { path in
                // let size = CGSize(width: 1.5, height: 1.5)
                let x = (rect.width )/CGFloat(points.count - 1)
                let max = Swift.max(points.map { $0.y }.max() ?? 0, rect.maxY)

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
                // let size = CGSize(width: 1.5, height: 1.5)
                let x = (rect.width )/CGFloat(points.count - 1)
                let max = Swift.max(points.map { $0.y }.max() ?? 0, rect.maxY)

                path.move(to: CGPoint(x: 0, y: rect.maxY))
                for p in points.enumerated() {
                    let y = rect.maxY - p.element.y.map(from: 0..<max, to: 0..<rect.maxY-1)
                    let l = CGPoint(x: CGFloat(p.offset) * x, y: y)

                    let h = rect.maxY - y

                    if h == 0 {
                        continue
                    }

                    path.move(to: l)
                    path.addRoundedRect(in: CGRect(origin: l, size: CGSize(width: 1, height: h)), cornerSize: CGSize(width: 1, height: 1))
                    path.closeSubpath()
                }
                path.closeSubpath()
            }
        }

    }

}
