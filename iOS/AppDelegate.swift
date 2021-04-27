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
