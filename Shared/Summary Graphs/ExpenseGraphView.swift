//
//  ExpenseGraphView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 8/04/21.
//

import SwiftUI

struct ExpenseGraphView: View {
    
    @ObservedObject private var datasource = Datasource()
    
    let points: [CGPoint] = [
        CGPoint(x: 0, y: 0),
        CGPoint(x: 0, y: 10),
        CGPoint(x: 0, y: 290),
        CGPoint(x: 0, y: 100),
        CGPoint(x: 0, y: 200),
        CGPoint(x: 0, y: 180),
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            
            HStack {
                Picker("", selection: $datasource.mode) {
                    ForEach(datasource.modes, id:\.self) { mode in
                        Text(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: datasource.mode) { value in
                    Logger.info("Modeo", value)
                    datasource.setInterval(mode: value)
                }
                Spacer()
                Image(systemName: "chevron.right.circle.fill")
                    .imageScale(.large)
                    .foregroundColor(.quaternaryLabel)
            }
         
            Text(DateIntervalFormatter.duration(range: datasource.interval))
                .font(.caption2)
                .foregroundColor(.secondary)
            
            PageView(steps: 1, currentPage: .constant(1)) { i  in
                
                Chart.Lines(datasource: [
                    Chart.DataSet(points: points, color: Color(Colors.primary)),
                    Chart.DataSet(points: points.reversed(), color: Color(UIColor.systemGroupedBackground))
                ])
            }

        }.cardView()
    }
    
}

extension ExpenseGraphView {
    
    class Datasource: ObservableObject {
        
        var modes = ["M", "W"]
        @Published var mode = "M"
        @Published var interval = DateInterval()
        
        init() {
            setInterval(mode: "M")
        }
        
        func setInterval(mode: String) {
            
            let date = Date()
            let componet: Calendar.Component =  mode == "M" ? .month: .weekOfMonth
            let start = date.withStart(of: componet)
            let end = date.withEnd(of: componet)
            
       
            interval = DateInterval(start: start, end: end)
        }
    }
    
}


