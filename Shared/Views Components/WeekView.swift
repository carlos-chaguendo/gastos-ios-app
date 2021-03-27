//
//  WeekView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 18/03/21.
//

import SwiftUI
import Combine


extension Notification.Name {
    
    enum WeekView {
        static var didSelectDate = Notification.Name(rawValue: "WeekViewDidSelectDate")
    }
}




public struct WeekView: View {
    
    public enum Mode: Int, Equatable {
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
    
    @Namespace private var currentDayID
    @State private var isScrollEnabled = false
    @State private var isAnimating = false
    @State private var offset: CGFloat = 0
    @State private var dayOffset: CGFloat = 0
    
    /// El alto del componente
    @Binding public var mode: Mode
    
    @ObservedObject private var viewModel: WeekendViewModel
    
    /// La altura de los dias de la semana, segun el tipo de fuente `caption`
    private let daysNamesHeight: CGFloat = 12
    
    /// El tamanio del una fila de dias
    private var daysRowHeight: CGFloat { viewModel.daysRowHeight }
    
    private var today = Date()
    
    
    private var datesByWeek: [WeekendViewModel.Row] { viewModel.datesByWeek }
    private var currentWeekOfMonth: Int { viewModel.currentWeekOfMonth }
    
    var caas = Set<AnyCancellable>()
    
    init() {
        self.init(mode: .constant(.monthly))
    }
    
    init(mode: Binding<WeekView.Mode> = .constant(.monthly), date: Date = Date()) {
        self._mode = mode
        self.viewModel = WeekendViewModel(date: date)
        self.today = Calendar.current.dateInterval(of: .day, for: date)!.start
    }
    
    init(mode: Binding<WeekView.Mode> = .constant(.monthly), model: WeekendViewModel) {
        self._mode = mode
        self.viewModel = model
        self.today = Calendar.current.dateInterval(of: .day, for: Date())!.start
    }
    
    
    public var body: some View {
        let width = UIScreen.main.bounds.size.width
        let dayWidth = (width / CGFloat(names.count)) - 1
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
            ScrollView(isScrollEnabled ? .horizontal : [] , showsIndicators: false) {
                
                Group {
                    switch mode {
                    case .weekend:
                        weekDayNumbers(dayWidth, dates: datesByWeek[currentWeekOfMonth].dates)
                            .transition(
                                AnyTransition.asymmetric(
                                    insertion:  AnyTransition.offset(x: 0, y: daysRowHeight * CGFloat(currentWeekOfMonth - 1)).combined(with: .move(edge: .bottom)),
                                    removal: AnyTransition.offset(x: 0, y: daysRowHeight * CGFloat(currentWeekOfMonth - 1)).combined(with: .move(edge: .bottom))
                                )
                            )
                            .animation(.default)
                        
                    case .monthly:
                        ForEach(datesByWeek, id: \.i) { week in
                            weekDayNumbers(dayWidth, dates: week.dates)
                                .transition(currentWeekOfMonth == week.i ?  (week.i == 0 ? .identity :.equal ): currentWeekOfMonth < week.i ? .bottomX : .topX )
                                .animation(.default)
                        }
                    }
                    
                    Text(DateFormatter.day.string(from: viewModel.selected))
                        .font(.subheadline)
                        .frame(width: width)
                        .foregroundColor(Color(#colorLiteral(red: 0.4156862745, green: 0.4666666667, blue: 0.5490196078, alpha: 1)))
                        .opacity(dayOffset == 0 ? 1 : 0)
                        .offset(x: dayOffset, y: 0)
                        .animation(.none)
                        .frame(minWidth: 0, maxWidth: .infinity)
 
                    
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
            .frame(height: viewModel.rowsHeight + 14)
            
  
 
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
            withAnimation(.easeInOut) {
                
                self.offset = -size
                let sign = size < 0 ? 1 : -1
                switch mode {
                case .weekend:
                    self.viewModel.selected = Calendar.current.date(byAdding: .day, value: 7 * sign, to: viewModel.selected)!
                    
                case .monthly: ()
                    self.viewModel.selected = Calendar.current.date(byAdding: .month, value: 1 * sign, to: viewModel.selected)!
                }
                
                self.offset = 0
                isAnimating = false
            }
        }
    }
    
    func animateCurrentDayLabel(direction: CGFloat) {
        self.dayOffset = direction * 40
        withAnimation(Animation.easeInOut(duration: 0.1)) {
            self.dayOffset = 0
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
        Text("\(Calendar.current.component(.day, from: date))")
            .if(date == today) { text in
                text.fontWeight(Font.Weight.bold)
            }
            .font(.system(size: 15))
            .frame(width: size, height: size, alignment: .center)
            .if(date == viewModel.selected) { text in
                text.background(Colors.primary)
                    .foregroundColor(.white)
                    .id(currentDayID)
                
            }.if(!Calendar.current.isDate(viewModel.selected, equalTo: date, toGranularity: .month)) { text in
                text.opacity(0.2)
            }.clipped()
            .cornerRadius(size/2)
            .onTapGesture {
                self.viewModel.selected = date
            }
    }
}

struct WeekView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VStack{
                let date = Calendar.gregorian.date(byAdding: .month, value: -2, to: Date())!
                WeekView(date: date)
                Text(DateFormatter.day.string(from: date))
                List {
                    Text("1")
                    Text("2")
                    Text("3")
                }
            }
            .navigationBarTitle("Calendar", displayMode: .inline)
            .navigationBarItems(leading: VStack {
                Text("MAR.")
                    .textCase(.uppercase)
                
                Text("2020")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.leading, -12)
            }, trailing: Text("CaemJ"))
            
        }.preferredColorScheme(.dark)
    }
}
