//
//  GastosApp.swift
//  Shared
//
//  Created by Carlos Andres Chaguendo Sanchez on 10/03/21.
//

import SwiftUI


// https://www.hackingwithswift.com/quick-start/swiftui
// https://github.com/SwiftUIX/SwiftUIX/
@main
struct GastosApp: App {
    
    
    @State var selected: Int = 0
    @State private var showingDetail = false
    
    private let addButtonSize: CGFloat = 60
    private let addButtonBorderSize : CGFloat = 4
    
    init() {
        
        #if !os(macOS)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().isTranslucent = true
        
        // UINavigationBar.appearance().tintColor = Colors.primary // Colores de los botones de navegacion
        
        UINavigationBar.appearance().barTintColor = .clear // Color de fondo
        
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().backgroundColor = .clear
        
        // UITableViewCell.appearance().backgroundColor = .clear
        
        #endif
    }
    
    @ViewBuilder var plusButton: some View {
        ZStack {
            Circle()
                .foregroundColor(.white)
                .frame(width:  addButtonSize, height: addButtonSize)
                .shadow(radius: 4)
            Image(systemName: "plus.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: addButtonSize - addButtonBorderSize , height: addButtonSize - addButtonBorderSize)
                .foregroundColor(Colors.primary)
        }.onTapGesture {
            self.showingDetail.toggle()
        }.sheet(isPresented: $showingDetail) {
            ExpenseItemFormView(isPresented: $showingDetail)
                .onTextChange { text in
                    Logger.info("Cambando 2", text)
                }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            TabBar {
                TransactionsView()
                    .tabItem {
                        TabBar.Page.Item(systemIconName: "homekit", tabName: "Home")
                    }
                
                
                NavigationView {
                    Text("Hola")
                        .navigationBarTitle("", displayMode: .inline)
                }.onAppear {
                    Logger.info("ssss", self.selected)
                }.tabItem {
                    
                    plusButton.offset(y: -40)
                    
                    
                }
                
                
                NavigationView {
                    Button("Arkit") {
                        self.selected -= 1
                    }.navigationBarTitle("", displayMode: .inline)
                }.onAppear {
                    Logger.info("ssss", self.selected)
                }.tabItem {
                    TabBar.Page.Item(systemIconName: "sun.min", tabName: "Setup")
                }
                
            }
            .selectedIndex($selected)
            .set(\.background, Color(Colors.background))
            .set(\.selectedColor, Color(Colors.primary))
            .background(Colors.background)
            
        }
    }
}
