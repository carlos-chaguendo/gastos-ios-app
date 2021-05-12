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
        //        PresentLinkView(destination:  ExpenseItemFormView()) {
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
            
        }.onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { not in
            appDelegate.scheduleAppAutoBackup()
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
                    
                }.onReceive(Publishers.didAddNewTransaction) { _ in
                    WidgetCenter.shared.reloadAllTimelines()
                }.onReceive(Publishers.didEditTransaction) { _ in
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
    
    @State private var notifications:[UNNotificationRequest] = []
    
    @State private var tasks: [BGTaskRequest] = []
    
    private let df = DateFormatter()
        .set(\.dateStyle, .full)
        .set(\.timeStyle, .full)
    
    @State var selected = 1
    
    
    @State var isDocumentPreviewPresented: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                //
                //
                
                //
                //
                
                Text("has \(number)")
                Text("u \(Int.random(in: 0..<100))")
                Text("updateView \(updateView)")
                    .onAppear {
                        self.updateView += 1
                    }
                
                FileImportButton()
                    .cardView()
                
                
                Button("clears Log") {
                    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("log.txt")
                    
                    try? FileManager.default.removeItem(at: url)
                    
                    
                }.foregroundColor(.systemRed)
                
                
                Button("Open Log") {
                    self.isDocumentPreviewPresented.toggle()
                }.sheet(isPresented: $isDocumentPreviewPresented) {
                    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("log.txt")
                    NavigationView {
                        DocumentInteractionController(url: url)
                            .navigationTitle("log.txt")
                    }
                }
                
        
           
                
                ForEach(notifications, id: \.identifier) { request in
                    
                    VStack {
                        Text(request.content.body)
                        
                        if let calendar =  request.trigger as? UNCalendarNotificationTrigger, let date = calendar.nextTriggerDate() {
                            Text(df.string(from: date))
                        }
                    }
                    
                }
                

//
                SegmentedView([1,2,3,4,5,6], selected: $selected) { e in
                    Text("\(e)")

                }.padding(.vertical)
                

                
            }
        }.background(Colors.background)
        .onAppear {
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                Logger.info("requests ", requests.count)
                
                notifications = requests
            }
            
            
            BGTaskScheduler.shared.getPendingTaskRequests { reuqest in
                Logger.info("tasks ", reuqest.count)
                tasks = reuqest
            }
        }
        
    }
}
