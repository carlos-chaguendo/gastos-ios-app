//
//  ContentView.swift
//  Shared
//
//  Created by Carlos Andres Chaguendo Sanchez on 10/03/21.
//

import SwiftUI
import Combine

struct TransactionsView: View {
    
    @State private var total: Double = 0.0
    
    @State private var datasource: [ExpenseItem] = []
        
    @ObservedObject private var weekendViewModel: WeekendViewModel
    
    @Environment(\.colorScheme) var colorScheme
    
    private let backcolor = Colors.groupedBackground
    private let systemBackground = Colors.background
            
    public private(set) var monthNames: [String] = {
        DateFormatter.day.shortStandaloneMonthSymbols
    }()
    
    init() {
        weekendViewModel = WeekendViewModel(date: Date(), mode: .weekend)
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().separatorInset = UIEdgeInsets(top: 0, left: 100, bottom: 0, right: 0)
        UITableView.appearance().backgroundColor = .clear // ColorSpace.color(light: systemBackground, dark: systemBackground)
    }
    
    private var currentMonthView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(DateFormatter.month.string(from: weekendViewModel.selected))
                .textCase(.uppercase)
            
            Text(DateFormatter.year.string(from: weekendViewModel.selected))
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
    
    private var showCalendarButton: some View {
        HStack {
            
            Button("Today") {
                self.weekendViewModel.selected = Calendar.current.dateInterval(of: .day, for: Date())!.start
                self.loadDataSource()
            }
            
            Button {
                withAnimation {
                    switch weekendViewModel.mode {
                    case.weekend: self.weekendViewModel.mode = .monthly
                    case .monthly: self.weekendViewModel.mode = .weekend
                    }
                }
            } label: {
                Image(systemName: "list.bullet.below.rectangle").font(.title2)
            }.frame(width: 38, height: 38)
            .if(weekendViewModel.mode == .monthly) {
                $0.background(Colors.primary)
                    .foregroundColor(.white)
            }
            .clipped()
            .cornerRadius(4)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack(alignment: .center, spacing: 0)  {

                    /// Navigation bar background color
                    Color(backcolor)
                        .frame(height: 100)
                    
                    WeekView(mode: $weekendViewModel.mode, model: weekendViewModel)
                        .background(backcolor)
                        .foregroundColor(.primary)
                    
                    Color(backcolor)
                        .frame(height: 40)

                    RoundedRectangle(cornerRadius: 25.0, style: .circular)
                        .fill(Color(systemBackground))
                        .offset(x: 0, y: -20)
                        .frame(height: 40)
                        .padding(.bottom, -20)
                        .if(colorScheme == .light) {
                            $0.shadow(color: Color(Colors.shadown),radius: 2, y: -3)
                        }

                    /// Se muetra el resumen del dia
                    header(width: geometry.size.width)
                        .frame(width: geometry.size.width, alignment: .leading)
                        //.background(Color(Colors.primary.withAlphaComponent(0.2)))
                        .padding(.top, -40)
                        .background(Color(systemBackground))
    
                    List {
                        ForEach(datasource) { item in
                            PresentLinkView(destination: ExpenseItemFormView(item)) {
                                ZStack {
                                    Rectangle()
                                        .fill(Color(systemBackground))
                                        .padding(.bottom, -6)
                                        .padding(.trailing, -14)
                                    
                                    ExpenseItemView(model: item)
                        
                                }
                            }.listRowBackground(Color(Colors.background))
                            
                        }.onDelete { index in
                            for offset in index {
                                let item = datasource[offset]
                                Service.remove(item)
                                datasource.remove(at: offset)
                            }
                            self.calculateTotal()
                        }
                    }
                    .listStyle(PlainListStyle())
                    
                    
                }.onReceive(Publishers.didAddNewTransaction) { item in
                    self.datasource.append(item)
                    self.calculateTotal()
                    Logger.info("Agrego una nueva transaccion", item)
                }.onReceive(Publishers.didEditTransaction) { item in
                    self.datasource.removeAll()
                    self.loadDataSource()
                    self.calculateTotal()
                    Logger.info("Edito una nueva transaccion", item)
                }.onReceive(WeekView.didSelectDate) { date in
                    self.datasource.removeAll()
                    self.loadDataSource()
                    self.weekendViewModel.marked = Service.summaryOf(month: weekendViewModel.selected)
                   
                    Logger.info("Date selected", date)
                }.onAppear {
                    self.loadDataSource()
                    self.weekendViewModel.marked = Service.summaryOf(month: weekendViewModel.selected)
                }
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarItems(leading: currentMonthView, trailing: showCalendarButton)
                .frame(height: geometry.size.height + 100)
                .offset(x: 0, y: -30)
                .background(Colors.background)
                
            }.foregroundColor(Colors.primary) // Bottones de navegacion
        }
    }
    
    /// La cabecera con el resumende movimientos del dia
    private func header(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(NumberFormatter.currency.string(from: NSNumber(value: total)) ?? "")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Colors.title)
        }
        .frame(width: width, alignment: .leading)
        .padding()
    }
    
    private func calculateTotal() {
        total = datasource.map { $0.value }.reduce(0, +)
    }
    
    private func loadDataSource() {
        if self.datasource.isEmpty {
            self.datasource = Service.getItems(in: weekendViewModel.selected)
            self.calculateTotal()
            Logger.info("tabs", datasource)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TransactionsView()
                .preferredColorScheme(.dark)
            
            TransactionsView()
                .preferredColorScheme(.light)
        }
        
    }
}


