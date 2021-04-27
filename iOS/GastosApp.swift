//
//  GastosApp.swift
//  Shared
//
//  Created by Carlos Andres Chaguendo Sanchez on 10/03/21.
//

import SwiftUI
import Combine
import WidgetKit
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
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
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
                    
                }.onReceive(Publishers.didAddNewTransaction) { item in
                    WidgetCenter.shared.reloadAllTimelines()
                }.onReceive(Publishers.didEditTransaction) { item in
                    WidgetCenter.shared.reloadAllTimelines()
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
        ScrollView {
            VStack(spacing: 10) {
                
 
                Text("has \(number)")
                Text("u \(Int.random(in: 0..<100))")
                Text("updateView \(updateView)")
                    .onAppear {
                        self.updateView += 1
                }
                
                FileImportButton()
                    .padding()

                ForEach([-1.0,-0.9,-0.8,-0.7,-0.6,-0.5,-0.4,-0.3,-0.2,-0.1,0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.8,1.0], id: \.self) { i in
                    Text("\(i)")
                        .background(Colors.background.shadeColor(factor: CGFloat(i)))
                }

                Divider()
        
            }
        }.background(Colors.background)
        
    }
}
