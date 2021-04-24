//
//  GastosApp.swift
//  Shared
//
//  Created by Carlos Andres Chaguendo Sanchez on 10/03/21.
//

import SwiftUI
import RealmSwift
import CoreServices
import UserNotifications

// https://www.hackingwithswift.com/quick-start/swiftui
// https://github.com/SwiftUIX/SwiftUIX/

@main
struct GastosApp: App {
    
    @State var selected: Int = 0
    @State private var showingDetail = false
    
    private let addButtonSize: CGFloat = 60
    private let addButtonBorderSize : CGFloat = 34
    
    @AppStorage("isFirstAppInstallation") private var isFirstAppInstallation = true
    
    init() {
        
        #if !os(macOS)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().isTranslucent = true
        
        UINavigationBar.appearance().tintColor = Colors.primary // Colores de los botones de navegacion
        UINavigationBar.appearance().barTintColor = .red // Color de fondo
        
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().separatorInset = UIEdgeInsets(top: 0, left: 100, bottom: 0, right: 0)
        UITableView.appearance().backgroundColor = .clear // ColorSpace.color(light: systemBackground, dark: systemBackground)
        
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
        .fullScreenCover(isPresented: $showingDetail) {
            ExpenseItemFormView()
            
        }
    }

    var body: some Scene {
        WindowGroup {
            if isFirstAppInstallation {
                iCloudRestoreView(restorationTerminated: $isFirstAppInstallation)
            } else {
                
                TabBar {
                  
                    SummaryGraphicsView().tabBarItem {
                            TabBar.Page.Item(systemIconName: "rectangle.3.offgrid", tabName: "Dashboard")
                        }
                    
                    
                    TransactionsView()
                        .tabBarItem {
                            TabBar.Page.Item(systemIconName: "homekit", tabName: "Home")
                        }
                    
                    NavigationView {
                        Text("Hola")
                            .navigationBarTitle("", displayMode: .inline)
                    }.onAppear {
                        Logger.info("ssss", self.selected)
                    }.tabBarItem {
                        plusButton
                            .offset(y: -20)
                    }
                    
                    
                    CapijaView()
                        .tabBarItem {
                            TabBar.Page.Item(systemIconName: "homepod.fill", tabName: "Categories")
                        }
                    
                    SettingsView()
                        .tabBarItem {
                            TabBar.Page.Item(systemIconName: "gearshape", tabName: "Settings")
                        }
                    
                    
                    
                }
                .selectedIndex($selected)
                .set(\.background, Color(Colors.background))
                .set(\.selectedColor, Color(Colors.primary))
                .background(Colors.background)
                .onAppear {
                    let center = UNUserNotificationCenter.current()
                    center.requestAuthorization(options: [.badge, .alert, .sound]) { granted, error in

                        center.setNotificationCategories(NotificationsCategory.all())
                        Logger.info("UNUserNotificationCenter granted", granted)
                        Logger.info("respuesta notifica error:", error)
   
                        
                    }
                }
            }
        }
    }
    
}


struct CapijaView: View {
    
    
    let  number = Int.random(in: 0..<100)
    
    @State var updateView = 0
    
    
    @State private var bgColor = Color.red
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                
                
                Button("Iclod ba") {
                    let backup = BackupService.init()
                    try? backup.startBackup(fileURL: Realm.Configuration.defaultConfiguration.fileURL!)
                }
                
                Button("Resrtore ba") {
                    let backup = Restore.init()
                    try? backup.getBackup()
                }
                
                
                Text("has \(number)")
                Text("u \(Int.random(in: 0..<100))")
                Text("updateView \(updateView)")
                    .onAppear {
                        self.updateView += 1
                    }
                
                FileImportButton()
                    .padding()
                
                
                
                
                
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
