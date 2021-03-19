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
    
    @State private var datasource = [
        ExpenseItem(title: "Tamal", value: 3500),
        ExpenseItem(title: "Perfume", value: 7800, tags: ["Varios"]),
        ExpenseItem(title: "Desayuno", value: 8900, tags: ["Comida","Marisol"]),
        ExpenseItem(title: "Tamal", value: 3500),
        ExpenseItem(title: "Tamal", value: 3500),
        ExpenseItem(title: "Tamal", value: 3500),
        ExpenseItem(title: "Tamal", value: 3500),
        ExpenseItem(title: "Tamal", value: 3500),
    ]
    
    @State private var calendarMode = WeekView.Mode.weekend
    
    private let backcolor = Colors.groupedBackground
    private let systemBackground = Colors.background
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack(alignment: .center, spacing: 0)  {

                    /// Navigation bar background color
                    Color(backcolor)
                        .frame(height: 100)
                    
                    WeekView(mode: $calendarMode)
                        //.padding(.top)
                        .background(backcolor)
                        .foregroundColor(.primary)
                    
                    Color(backcolor)
                        .frame(height: 40)

                    RoundedRectangle(cornerRadius: 25.0, style: .circular)
                        .fill(Color(systemBackground))
                        .offset(x: 0, y: -20)
                        .frame(height: 40)
                        .padding(.bottom, -20)
                        .shadow(color: Color(Colors.shadown),radius: 2, y: -3)
                    
                    
                    /// Se muetra el resumen del dia
                    header(width: geometry.size.width)
                        .frame(width: geometry.size.width, alignment: .leading)
                        //.background(Color(Colors.primary.withAlphaComponent(0.2)))
                        .padding(.top, -40)
                        .background(Color(systemBackground))
    

                    
                    List {
                        ForEach(datasource) { item in
                            ExpenseItemView(model: item)
                                .listRowBackground(Color(Colors.background))
                        }
                    }.listStyle(PlainListStyle())
                    
                    
                }.onReceive(Publishers.didAddNewTransaction) { item in
                    self.datasource.append(item)
                    Logger.info("Agrego una nueva transaccion", item)
                }
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarItems(trailing: showCalendarButton)
                .frame(height: geometry.size.height + 100)
                .offset(x: 0, y: -30)
                .background(Colors.background)
                
            }.foregroundColor(Colors.primary) // Bottones de navegacion
        }
    }
    
    
    private var showCalendarButton: some View {
        Button(action: {
            withAnimation {
                switch calendarMode {
                case.weekend: self.calendarMode = .monthly
                case .monthly:  self.calendarMode = .weekend
                }
            }
        }, label: {
            Image(systemName: "list.bullet.below.rectangle").font(.title2)
        }).frame(width: 30, height: 30)
    }
    
    /// La cabecera con el resumende movimientos del dia
    private func header(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(NumberFormatter.currency.string(from: NSNumber(value: total)) ?? "")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Colors.title)
            
            Text(DateFormatter.day.string(from: Date()))
                .font(.subheadline)
                .foregroundColor(Color(#colorLiteral(red: 0.4156862745, green: 0.4666666667, blue: 0.5490196078, alpha: 1)))
            
        }
        .frame(width: width, alignment: .leading)
        .padding()
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
