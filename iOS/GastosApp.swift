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
import BackgroundTasks

// https://www.hackingwithswift.com/quick-start/swiftui
// https://github.com/SwiftUIX/SwiftUIX/

@main
struct GastosApp: App {
    
    @State var selected: Int = 0
    @State private var showingDetail = false
    
    private let addButtonSize: CGFloat = 60
    private let addButtonBorderSize: CGFloat = 34
    
    @AppStorage("isFirstAppInstallation") private var isFirstAppInstallation = true
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @ViewBuilder var plusButton: some View {
        ZStack {
            Circle()
                .foregroundColor(.white)
                .frame(width: addButtonSize, height: addButtonSize)
                .shadow(radius: 4)
            Image(systemName: "plus")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: addButtonSize - addButtonBorderSize, height: addButtonSize - addButtonBorderSize)
                .foregroundColor(Colors.primary)
        }
        .onTapGesture {
            self.showingDetail.toggle()
        }
        .sheet(isPresented: $showingDetail) {
            ExpenseItemFormView()
            
        }.onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            appDelegate.scheduleAppAutoBackup()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if isFirstAppInstallation {
                iCloudRestoreView(restorationTerminated: $isFirstAppInstallation)
            } else {
                
                TabBar {
                    
                    SummaryGraphicsView()
                        .tabBarItem {
                            TabBar.Page.Item(systemIconName: "rectangle.3.offgrid", tabName: "Dashboard")
                        }
                    
                    TransactionsView()
                        .tabBarItem {
                            TabBar.Page.Item(systemIconName: "homekit", tabName: "Home")
                        }
                    
                    EmptyView()
                        .tabBarItem {
                            plusButton.offset(y: -20)
                        }
                    
                    DebugView()
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
                    
                }.onReceive(Publishers.didAddNewTransaction) { _ in
                    WidgetCenter.shared.reloadAllTimelines()
                }.onReceive(Publishers.didEditTransaction) { _ in
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
        }
    }
    
}
