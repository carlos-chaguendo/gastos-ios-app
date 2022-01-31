//
//  WeekView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 18/03/21.
//

import SwiftUI
import Combine

public struct WeekView: View {

    public enum Mode: Int, Equatable {
        case weekend
        case monthly
    }

    @Namespace private var currentDayID
    @State private var isScrollEnabled = false
    @State private var isAnimatingPageChanged = false
    @State private var offset: CGFloat = 0
    @State private var dayOffset: CGFloat = 0
    @Namespace private var namespace
    @ObservedObject private var viewModel: WeekendViewModel

    /// La altura de los dias de la semana, segun el tipo de fuente `caption`
    private let daysNamesHeight: CGFloat = 12

    /// El tamanio del una fila de dias
    private var daysRowHeight: CGFloat { viewModel.daysRowHeight }

    private var today = Date()

    private var datesByWeek: [WeekendViewModel.Row] { viewModel.datesByWeek }
    private var currentWeekOfMonth: Int { viewModel.currentWeekOfMonth }

    public var dayGenerator: ((Date, CGFloat) -> AnyView)?

    init() {
        self.init(date: Date())
    }

    init(date: Date = Date()) {
        self.init(model: WeekendViewModel(date: date))
    }

    init(model: WeekendViewModel) {
        self.viewModel = model
        self.today = Calendar.current.dateInterval(of: .day, for: Date())!.start
    }

    init(model: WeekendViewModel, content: ((Date, CGFloat) -> AnyView)?) {
        self.init(model: model)
        self.dayGenerator = content
    }

    public var body: some View {
        GeometryReader { reader in
            let width = reader.size.width
            let dayWidth = (width / CGFloat(viewModel.weekDayNames.count)) // - 1

            VStack(alignment: .center, spacing: 0) {

                /// Weekend day names
                HStack(alignment: .center, spacing: 0) {
                    ForEach(viewModel.weekDayNames, id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(width: dayWidth, height: 14)
                    }
                }

                /// Weekend Day Numbers
                ScrollView(isScrollEnabled ? .horizontal : [], showsIndicators: false) {

                    Group {
                        switch viewModel.mode {
                        case .weekend:
                            weekDayNumbers(dayWidth, dates: datesByWeek[currentWeekOfMonth].dates)
                                .transition(
                                    AnyTransition.asymmetric(
                                        insertion: AnyTransition.offset(x: 0, y: daysRowHeight * CGFloat(currentWeekOfMonth - 1)).combined(with: .move(edge: .bottom)),
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
            }
        }.frame(height: viewModel.rowsHeight + 54)
    }

    /// Ejecuta la animacion de cambiar pagina
    /// - Parameter size: tancho de la pantalla
    /// - Parameter updateSelected: un boleano que indica si tien que actualizar la fecha selecionada actualmente al cambiar de pagina
    func pageChangeAnimation(screenWidth size: CGFloat, updateSelected: Bool = true) {
        guard !isAnimatingPageChanged else { return }

        Logger.info("Page change", size)
        // isScrollEnabled = false

        isAnimatingPageChanged = true
        withAnimation(.easeInOut) {
            self.offset = size
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {

            self.offset = -size

            if updateSelected {
                let sign = size < 0 ? 1 : -1
                switch viewModel.mode {
                case .weekend:
                    self.viewModel.selected = Calendar.current.date(byAdding: .day, value: 7 * sign, to: viewModel.selected)!

                case .monthly: ()
                    self.viewModel.selected = Calendar.current.date(byAdding: .month, value: 1 * sign, to: viewModel.selected)!
                }
            }

            withAnimation(.easeInOut) {
                self.offset = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    isAnimatingPageChanged = false
                }
            }
        }
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
            .if(viewModel.marked.contains(date)) { text in
                text.background(
                    Circle()
                        .fill(Color.secondary.opacity(0.6))
                        .frame(width: 6, height: 6, alignment: .center)
                        .offset(y: (size/2) - 6)
                )
            }
            .if(date == viewModel.selected) { text in
                text.background(Colors.primary)
                    .foregroundColor(.white)
                    .id(currentDayID)

            }.if(!Calendar.current.isDate(viewModel.selected, equalTo: date, toGranularity: .month)) { text in
                text.opacity(0.2)
            }.clipped()
            .cornerRadius(size/2)
            .onTapGesture {
                /// Se seleciono una fecah por fuera del mes actual
                if date >= viewModel.month.end {
                    pageChangeAnimation(screenWidth: -UIScreen.main.bounds.size.width, updateSelected: false)
                }
                if date < viewModel.month.start {
                    pageChangeAnimation(screenWidth: UIScreen.main.bounds.size.width, updateSelected: false)
                }

                self.viewModel.selected = date
            }
    }

    @ViewBuilder
    func weekDayNumbers(_ dayWidth: CGFloat, dates: [Date]) -> some View {
        HStack(alignment: VerticalAlignment.firstTextBaseline, spacing: 0) {
            ForEach(dates, id: \.self) { date in
                if let generator = dayGenerator {
                    generator(date, daysRowHeight)
                        .frame(width: dayWidth, height: daysRowHeight)
                        .offset(x: self.offset, y: 0)

                } else {
                    dayView(date: date, size: daysRowHeight - 6)
                        .frame(width: dayWidth, height: daysRowHeight)
                        .offset(x: self.offset, y: 0)
                }
            }
        }
        .lineLimit(1)
    }
}

struct WeekView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VStack {
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
