//
//  AppDelegate.swift
//  Gastos
//
//  Created by Carlos Andres Chaguendo Sanchez on 27/04/21.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Your code here")
        
        
        #if !os(macOS)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = Colors.background
        appearance.titleTextAttributes = [.foregroundColor: Colors.title]
        appearance.largeTitleTextAttributes = [.foregroundColor: Colors.title]
        appearance.shadowImage = UIImage()
        appearance.shadowColor = Colors.background
        
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().tintColor = Colors.primary // Colores de los botones de
        UINavigationBar.appearance().isTranslucent = true
        
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().shadowImage = UIImage()
        
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().separatorInset = UIEdgeInsets(top: 0, left: 100, bottom: 0, right: 0)
        UITableView.appearance().backgroundColor = .clear // ColorSpace.color(light: systemBackground, dark: systemBackground)
        
        #endif
        
        UNUserNotificationCenter.current().delegate = self
        return true
    }
}



extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Logger.info("didRegisterForRemoteNotificationsWithDeviceToken")

    }
    
    // Cuando la app recibe la nofiticacion en estado background y se da click en la notificación
    // Cuando esta en el front y llega la notificacion
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Logger.info("Notification while the app is in foreground with UNUserNotificationCenterDelegate:: [didReceive]: UNNotificationResponse")
        Logger.info("Response:", response)
        Logger.info("Info:", response.notification.request.content.userInfo)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        Logger.info("Es una notificacion remota, con la app activa, debe mostrar Notificacion solo si no es interna")
        Logger.info(notification.debugDescription)
        completionHandler([.banner, .sound])
    }
}
