//
//  WeekView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 18/03/21.
//

import SwiftUI


extension AnyTransition {
    
    static let top = AnyTransition.asymmetric(insertion: AnyTransition.move(edge: .top).combined(with: .opacity),  removal:  AnyTransition.move(edge: .top).combined(with: .opacity))
    static let bottom = AnyTransition.asymmetric(insertion: .move(edge: .bottom),  removal: .move(edge: .bottom))
}

struct WeekView: View {
    
    enum Mode: Int, Equatable {
        case weekend
        case monthly
    }
    
    public private(set) var names: [String] = {
        DateFormatter.day.shortStandaloneWeekdaySymbols
    }()
    
    @Namespace private var currentDayID
    @State private var isScrollEnabled = false
    @State private var isAnimating = false
    @State private var offset: CGFloat = 0
    
    /// El alto del componente
    @State public private(set) var height: CGFloat = 0
    @Binding public var mode: Mode
    
    
    /// La altura de los dias de la semana, segun el tipo de fuente `caption`
    private let daysNamesHeight: CGFloat = 12
    
    /// El tamanio del una fila de dias
    private let daysRowHeight: CGFloat = 40
    
    
    /// Numero de filas depende del tipo de vista y el mes que se este mostrando
    @State private var numberOfRows: CGFloat = 1
    
    init() {
        self._mode = .constant(.weekend)
    }
    
    init(mode: Binding<WeekView.Mode>) {
        self._mode = mode
    }
    
    var body: some View {
        let width = UIScreen.main.bounds.size.width
        let dayWidth = width / CGFloat(names.count)
        VStack(alignment: .center, spacing: 0) {
            
            /// Weekend day names
            HStack(alignment: .center, spacing: 0) {
                ForEach(names, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(width: dayWidth)
                }
            }
            
            /// Weekend Day Numbers
            ScrollViewReader { scrollReader in
                ScrollView(isScrollEnabled ? .horizontal : [] , showsIndicators: false) {
                    
                    Group {
                        
//
//                                      if i == selectedIndex {}
//                        }
                        //ForEach(0..<5) { i in
                            switch mode {
                            case .weekend:
                                // par abrir .identy
                                // para cerra .bottom
                               
                                weekDayNumbers(dayWidth, offset: 15)
                      
                                    .transition(AnyTransition.asymmetric(
                                                    insertion:  AnyTransition.offset(x: 0, y: daysRowHeight * 1).combined(with: .move(edge: .bottom)),
                                                    removal: AnyTransition.offset(x: 0, y: daysRowHeight * 1).combined(with: .move(edge: .bottom)))
                                    )
                                    .animation(.default)
                            case .monthly:
                                weekDayNumbers(dayWidth, offset: 1).transition(.top).animation(.default)
                                weekDayNumbers(dayWidth, offset: 8).transition(.top).animation(.default)
                                weekDayNumbers(dayWidth, offset: 15).transition(
                                    AnyTransition.asymmetric(
                                        insertion:  AnyTransition.move(edge: .bottom).combined(with: .opacity),
                                            removal: AnyTransition.move(edge: .bottom).combined(with: .opacity))
                                ).animation(.default)
                                weekDayNumbers(dayWidth, offset: 29).transition(.bottom).animation(.default)
                                weekDayNumbers(dayWidth, offset: 43).transition(.bottom).animation(.default)
                            }
                       // }
                        
                        
                    }.readOffset(named: "WeekendDayNumbers") { y in
                        let tolerance = dayWidth / 2
                        if y.maxX < width - tolerance {
                            pageChangeAnimation(screenWidth: -width)
                        }
                        
                        if y.minX > tolerance {
                            pageChangeAnimation(screenWidth: width)
                        }
                    }.onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            self.isScrollEnabled = true
                            print("On apera grpup")
                            /// No se necesita simpre y cuando aparezcan solo los 7 dias de la semana
                            /// scrollReader.scrollTo(currentDayID, anchor: .none)
                        }
                    }
                    
                }
                .coordinateSpace(name: "WeekendDayNumbers")
                //.frame(height: numberOfRows * daysRowHeight)
                //.offset(x: offset, y: 0)
            }
            
        }
    }
    
    func updateHeight() {
        self.height = daysRowHeight * numberOfRows + daysNamesHeight
    }
    
    /// Ejecuta la animacion de cambiar pagina
    /// - Parameter size: tancho de la pantalla
    func pageChangeAnimation(screenWidth size: CGFloat) {
        guard !isAnimating else { return }
        
        Logger.info("Page change", size)
        //isScrollEnabled = false

        isAnimating = true
        withAnimation(.easeInOut)  {
            self.offset = size
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.offset = -size
            withAnimation(.easeInOut) {
                self.offset = 0
                isAnimating = false
            }
        }
        
        self.height = daysRowHeight * numberOfRows + daysNamesHeight
    }
    
    @ViewBuilder
    func weekDayNumbers(_ dayWidth: CGFloat, offset: Int) -> some View {
        HStack(alignment: .center, spacing: 0) {
            ForEach(0..<names.count) { i in
                dayView(number: i + offset, size: dayWidth - 20)
                    .frame(width: dayWidth, height: daysRowHeight)
                    .offset(x: self.offset, y: 0)
            }
        }
        .lineLimit(1)
    }
    
    
    /// Envuelve un text dentro de una vista, con margenes para le numero del dia
    /// - Parameters:
    ///   - number: Numero del dia
    ///   - size: Tamanio del item selecionado
    /// - Returns: View
    func dayView(number: Int, size: CGFloat) -> some View {
        Text("\(number)")
            .font(.system(size: 15))
            .frame(width: size, height: size, alignment: .center)
            .if(number == 20) { text in
                text.background(.systemRed)
                    .foregroundColor(.white)
                    .id(currentDayID)
                
            }.clipped()
            .cornerRadius(size/2)
    }
}

struct WeekView_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            WeekView()
            Text("Header")
            List {
                Text("1")
                Text("2")
                Text("3")
            }
        }.preferredColorScheme(.dark)
    }
}
