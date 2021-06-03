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
    
    @Environment(\.isForXcocePreview) var isPreview
    @State var setPercents: Bool = false
    @State var setPercents2: Bool = false
    
    var animatable: Bool = true
    var lineWidth: CGFloat = 8
    var lineSpacing: CGFloat = 0.04
    var lineBackGround: Color = Color.secondary
    
    init(animatable: Bool = true, lineWidth: CGFloat = 8, lineSpacing: CGFloat = 0.04, lineBackGround: Color = .secondary, @ArrayBuilder<Entry> make: () -> [Entry]) {
        self.init(
            animatable: animatable,
            lineWidth: lineWidth,
            lineSpacing: lineSpacing,
            lineBackGround: lineBackGround,
            make()
        )
    }
    
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
                // let previous = CGFloat(percents[safe: i - 1 ]?.value ?? 0)

                let includeAnimation = animatable && !isPreview ? setPercents : true
                
                Circle()
                    .trim(from: includeAnimation ? entry.previous : 0, to: includeAnimation ? entry.value + entry.previous - lineSpacing : 0)
                    // .fill()
                    .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                    .foregroundColor(entry.color.opacity(0.6))
                    .onAppear {
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
                    }// .rotationEffect(Angle.degrees(-90))
 
            }
            
        }
    }
    
}

struct ContentX: View {
    
    @State var value: Double = 0.5
    
    @State  var selected = "2"
    @State   var values = ["1", "2", "3"]
    
    var body: some View {
        VStack {
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
                     .init(color: .red, value: 0.333)
                 ])
                 
                 CircularChart([
                    .init(color: .green, value: CGFloat(value))
                 ]).padding()
                ProgressView(value: 0.6) /// here!
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.red))
            }
     
            VStack {
                
                Text("Value \(value)")
                    .font(.title)
                    .fontWeight(.bold)
                    .blendMode(.overlay)
                
                ProgressView("s", value: 0.5)
                
                Slider(value: $value, in: 0...1)
          
            }.padding().background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .leading, endPoint: .trailing))
           
            Text("Clipped text in a circle")
                .frame(width: 175, height: 100)
                .foregroundColor(Color.white)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .circular))
            
            SegmentedView(values, selected: $selected) { e in
                Text(e)
            }
            
        }
    }
}

struct CircularChart_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ContentX()
        
       .padding()
        
        .preferredColorScheme(.dark)
    }
}
