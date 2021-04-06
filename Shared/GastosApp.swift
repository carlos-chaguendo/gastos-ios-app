//
//  GastosApp.swift
//  Shared
//
//  Created by Carlos Andres Chaguendo Sanchez on 10/03/21.
//

import SwiftUI
import CoreServices


// https://www.hackingwithswift.com/quick-start/swiftui
// https://github.com/SwiftUIX/SwiftUIX/
@main
struct GastosApp: App {
    
    @State var selected: Int = 0
    @State private var showingDetail = false
    
    private let addButtonSize: CGFloat = 60
    private let addButtonBorderSize : CGFloat = 34
    
    init() {
        
        #if !os(macOS)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().isTranslucent = true
        
        // UINavigationBar.appearance().tintColor = Colors.primary // Colores de los botones de navegacion
        
        UINavigationBar.appearance().barTintColor = .clear // Color de fondo
        
        UITableView.appearance().separatorStyle = .none
        //UITableView.appearance().backgroundColor = .clear
        
        // UITableViewCell.appearance().backgroundColor = .clear
        
        #endif
    }
    
    @ViewBuilder var plusButton: some View {
//        PresentLinkView(destination:  ExpenseItemFormView()) {
            ZStack {
                Circle()
                    .foregroundColor(.white)
                    .frame(width:  addButtonSize, height: addButtonSize)
                    .shadow(radius: 4)
                Image(systemName: "plus")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: addButtonSize - addButtonBorderSize , height: addButtonSize - addButtonBorderSize)
                    .foregroundColor(Colors.primary)
            }
            .onTapGesture {
                self.showingDetail.toggle()
            }
//        }
        
        

        
        .fullScreenCover(isPresented: $showingDetail) {
            ExpenseItemFormView()
          
        }
    }
    
    var transactionsView = TransactionsView()
    
    var body: some Scene {
        WindowGroup {
            TabBar {
                transactionsView
                    .tabItem {
                        TabBar.Page.Item(systemIconName: "homekit", tabName: "Home")
                    }
                
                NavigationView {
                    Text("Hola")
                        .navigationBarTitle("", displayMode: .inline)
                }.onAppear {
                    Logger.info("ssss", self.selected)
                }.tabItem {
                    plusButton
                        .offset(y: -30)
                }
                
                NavigationView {
                    FileImportButton()
                }.onAppear {
                    Logger.info("ssss", self.selected)
                }.tabItem {
                    TabBar.Page.Item(systemIconName: "sun.min", tabName: "Setup")
                }
                
                Button("Add Category") {
                    Service.addCategory(Catagory {
                         $0.name = "Comida"
                    })
                    
                    Service.addTag(Tag{
                        $0.name = "Comida"
                    })
                    
                    Service.addTag(Tag{
                        $0.name = "Trago"
                    })
                    
                    Service.addTag(Tag{
                        $0.name = "Marisol"
                    })
                    
                    Service.addTag(Tag{
                        $0.name = "Popayan"
                    })
                    
                    Service.addWallet(Wallet {
                        $0.name = "Bancolombia"
                    })
                    
                    Service.addWallet(Wallet {
                        $0.name = "Efectivo"
                    })
                    
                    Service.addWallet(Wallet {
                        $0.name = "Davivienda"
                    })
                
                }.tabItem {
                    TabBar.Page.Item(systemIconName: "homepod.fill", tabName: "Categories")
                }
                
            }
            .selectedIndex($selected)
            .set(\.background, Color(Colors.background))
            .set(\.selectedColor, Color(Colors.primary))
            .background(Colors.background)
        }
    }

}
