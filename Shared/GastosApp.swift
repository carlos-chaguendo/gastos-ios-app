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

//@main
struct GastosAppDebug: App {
    
    @State  var selected: Int = 0
    
    var body: some Scene {
        WindowGroup {
            
            TabBar {
                
                SummaryGraphicsView()
                    .tabBarItem {
                        Text("A")
                    }
                
                SummaryGraphicsView()
                    .tabBarItem {
                        Text("B")
                    }
                
                CapijaView()
                    .tabBarItem {
                        Text("C")
                    }
                
                
            }.selectedIndex($selected)
        }
    }
}

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
    
    var summary = SummaryGraphicsView()
    
    var capj = CapijaView()
    
    var body: some Scene {
        WindowGroup {
            TabBar {
                summary
                    .tabBarItem {
                        TabBar.Page.Item(systemIconName: "rectangle.3.offgrid", tabName: "Dashboard")
                    }
                
                
                transactionsView
                    .tabBarItem {
                        TabBar.Page.Item(systemIconName: "homekit", tabName: "Home")
                    }
                
   
                CapijaView()
                    .tabBarItem {
                        TabBar.Page.Item(systemIconName: "homepod.fill", tabName: "Categories")
                    }
                
                NavigationView {
                    Text("Hola")
                        .navigationBarTitle("", displayMode: .inline)
                }.onAppear {
                    Logger.info("ssss", self.selected)
                }.tabBarItem {
                    plusButton
                        .offset(y: -30)
                }
                
            }
            .selectedIndex($selected)
            .set(\.background, Color(Colors.background))
            .set(\.selectedColor, Color(Colors.primary))
            .background(Colors.background)
        }
    }

}


struct CapijaView: View {
    
    
    let  number = Int.random(in: 0..<100)
    
    @State var updateView = 0
    
    
    @State private var bgColor = Color.red
    
    var body: some View {
        NavigationView {
            VStack {
                
                Text("has \(number)")
                Text("u \(Int.random(in: 0..<100))")
                Text("updateView \(updateView)")
                    .onAppear {
                        self.updateView += 1
                    }
                
                FileImportButton()
                    .padding()
                
                
                
                VStack {
                         ColorPicker("Set the background color", selection: $bgColor)
                     }
                     .frame(maxWidth: .infinity, maxHeight: .infinity)
                     .background(bgColor)
                
                Button {
                    
                    
              
                    
                    let color: UInt32 = 0x257D81
                    let uicolor = ColorSpace.from(hex: color)
                    
                } label: {
            
                    
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
                
                }
        }
        }
    }
}
