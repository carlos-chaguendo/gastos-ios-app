//
//  WeekView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 18/03/21.
//

import SwiftUI
import Combine

extension AnyTransition {
    
    static let topX = AnyTransition.asymmetric(
        insertion: AnyTransition.move(edge: .top).combined(with: .opacity),
        removal:  AnyTransition.move(edge: .top).combined(with: .opacity)
    )
    
    static let bottomX = AnyTransition.asymmetric(
        insertion: .move(edge: .bottom),
        removal: .move(edge: .bottom)
    )
    
    static let equal = AnyTransition.asymmetric(
        insertion: AnyTransition.move(edge: .bottom).combined(with: .opacity),
        removal: AnyTransition.move(edge: .bottom).combined(with: .opacity)
    )
}

extension Notification.Name {
    
    enum WeekView {
        static var didSelectDate = Notification.Name(rawValue: "WeekViewDidSelectDate")
    }
}

struct WeekView: View {
    
    enum Mode: Int, Equatable {
        case weekend
        case monthly
    }
    
    /// El usuario seleciono una fecha
    static var didSelectDate: AnyPublisher<Date, Never> {
        NotificationCenter.default.publisher(for: Notification.Name.WeekView.didSelectDate)
            .compactMap { $0.object as? Date }
            .eraseToAnyPublisher()
    }
    
    public private(set) var names: [String] = {
        DateFormatter.day.shortStandaloneWeekdaySymbols
    }()
    
    @Environment(\.calendar) var calendar
    
    @Namespace private var currentDayID
    @State private var isScrollEnabled = false
    @State private var isAnimating = false
    @State private var offset: CGFloat = 0
    
    /// El alto del componente
    @State public private(set) var height: CGFloat = 0
    @Binding public var mode: Mode
    
    @State private var selected = Date()
    
    
    /// La altura de los dias de la semana, segun el tipo de fuente `caption`
    private let daysNamesHeight: CGFloat = 12
    
    /// El tamanio del una fila de dias
    private let daysRowHeight: CGFloat = 40
    

    

    private var today = Date()
    private var datesByWeek: [[Date]] = []
    

    // MARK:  Rangos
    private var month: DateInterval
    private var firstWeek: DateInterval
    private var lastWeek: DateInterval
    
    
    /// El numero de la semana en el mes
    private var currentWeekOfMonth: Int { selected.number(of: .weekOfMonth, since: firstWeek.start)}

    
    init() {
        self.init(mode: .constant(.monthly))
    }
    
    init(mode: Binding<WeekView.Mode> = .constant(.monthly), date: Date = Date()) {
        self._mode = mode
        
        self.month = Calendar.current.dateInterval(of: .month, for: date)!
        self.firstWeek = Calendar.current.dateInterval(of: .weekOfMonth, for: month.start)!
        self.lastWeek = Calendar.current.dateInterval(of: .weekOfMonth, for: month.end)!
        
        self.selected = Calendar.current.dateInterval(of: .day, for: date)!.start
        self.today = Calendar.current.dateInterval(of: .day, for: date)!.start

        let numberOfDays = lastWeek.end.number(of: .day, since: firstWeek.start)


   
        var week:[Date] = []
        
        for i in 0..<numberOfDays {
            week.append(Calendar.gregorian.date(byAdding: .day, value: i, to: firstWeek.start)!)
        }

        datesByWeek = week.chunked(into: 7)
            
        
        
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
                        switch mode {
                        case .weekend:
                       
                            weekDayNumbers(dayWidth, dates: datesByWeek[currentWeekOfMonth])
                                .transition(
                                    AnyTransition.asymmetric(
                                        insertion:  AnyTransition.offset(x: 0, y: daysRowHeight * CGFloat(currentWeekOfMonth - 1)).combined(with: .move(edge: .bottom)),
                                        removal: AnyTransition.offset(x: 0, y: daysRowHeight * CGFloat(currentWeekOfMonth - 1)).combined(with: .move(edge: .bottom))
                                    )
                                )
                                .animation(.default)
                        case .monthly:
                            
                            ForEach(0..<datesByWeek.count) { i in
                                weekDayNumbers(dayWidth, dates: datesByWeek[i])
                                    .transition(currentWeekOfMonth == i ? .equal : currentWeekOfMonth < i ? .bottomX : .topX )
                                    .animation(.default)
                            }
                        }
                        
                        
                    }.readOffset(named: "WeekendDayNumbers") { y in
                        let tolerance = dayWidth / 2
                        if y.maxX < width - tolerance {
                            pageChangeAnimation(screenWidth: -width)
                        }
                        
                        if y.minX > tolerance {
                            pageChangeAnimation(screenWidth: width)
                        }
                    }.onAppear {
                        withAnimation {
                            self.selected = Calendar.current.dateInterval(of: .day, for: selected)!.start
                        }
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
    }
    
    @ViewBuilder
    func weekDayNumbers(_ dayWidth: CGFloat, dates: [Date]) -> some View {
        HStack(alignment: VerticalAlignment.firstTextBaseline, spacing: 0) {
            ForEach(dates, id: \.self) { date in
                dayView(date: date, size: daysRowHeight - 6)
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
    func dayView(date: Date, size: CGFloat) -> some View {
        Text("\(calendar.component(.day, from: date))")
            .if(date == today) { text in
                text.fontWeight(Font.Weight.bold)
            }
            .font(.system(size: 15))
            .frame(width: size, height: size, alignment: .center)
            .if(date == selected) { text in
                text.background(Colors.primary)
                    .foregroundColor(.white)
                    .id(currentDayID)
                
            }.if(!calendar.isDate(self.selected, equalTo: date, toGranularity: .month)) { text in
                text.opacity(0.2)
            }.clipped()
            .cornerRadius(size/2)
            .onTapGesture {
                NotificationCenter.default.post(name: Notification.Name.WeekView.didSelectDate, object: date)
                self.selected = date
            }
    }
}

struct WeekView_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            
            let date = Calendar.gregorian.date(byAdding: .month, value: -2, to: Date())!
            
            WeekView(date: date)
            Text(DateFormatter.day.string(from: date))
            List {
                Text("1")
                Text("2")
                Text("3")
            }
        }.preferredColorScheme(.dark)
    }
}
