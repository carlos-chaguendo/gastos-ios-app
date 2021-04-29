//
//  AppDelegate.swift
//  Gastos
//
//  Created by Carlos Andres Chaguendo Sanchez on 27/04/21.
//

import UIKit
import BackgroundTasks

class AppDelegate: NSObject, UIApplicationDelegate {
    
    
    private static let file: FileHandlerOutputStream? = {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("log.txt")


        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: nil, attributes: [:])
        }

        let fileHandle = try! FileHandle(forUpdating: url)
        return FileHandlerOutputStream(fileHandle)
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
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
        UINavigationBar.appearance().backgroundColor = Colors.background
        
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().separatorInset = UIEdgeInsets(top: 0, left: 100, bottom: 0, right: 0)
        UITableView.appearance().backgroundColor = .clear // ColorSpace.color(light: systemBackground, dark: systemBackground)
        
        #endif
        
        UNUserNotificationCenter.current().delegate = self

        // Fetch data once an hour.
        // MARK: Registering Launch Handlers for Tasks
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.mayorgafirm.Gastos.backup", using: nil) { task in
            // Downcast the parameter to an app refresh task as this identifier is used for a refresh request.
            self.handleAppBackUp(task: task as! BGProcessingTask)
        }
        self.pprint("app start \(Date())")
        
        
   
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        pprint("applicationWillResignActive")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        pprint("Enter fore ground")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.pprint("applicationDidEnterBackground \(Date())")
        scheduleAppAutoBackup()
    }
    
    func scheduleAppAutoBackup() {
        pprint("scheduleAppAutoBackup \(Date())")
        let request = BGProcessingTaskRequest(identifier: "com.mayorgafirm.Gastos.backup")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 5 * 60)
//        request.requiresNetworkConnectivity = true
        
        do {
            try BGTaskScheduler.shared.submit(request)
            
            BGTaskScheduler.shared.getPendingTaskRequests { reuqest in
                Logger.info("tasks ", reuqest.count)
                
            }
        
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
        
        
        
    }
    
    func handleAppBackUp(task: BGProcessingTask) {
        scheduleAppAutoBackup()
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        
        let file = AppDelegate.file
        
        let backupOperation = BlockOperation {
            self.pprint("Termino la operacion")
       
        }
        
        task.expirationHandler = {
            // After all operations are cancelled, the completion block below is called to set the task to complete.
            queue.cancelAllOperations()
        }
        
        backupOperation.completionBlock = {
            task.setTaskCompleted(success: true)
        }
        
        queue.addOperation(backupOperation)
        
   
    }
    
    func pprint(_ message: String) {
        if var output = AppDelegate.file {
            Swift.print(message, separator: "\t\t\t", terminator: "\n", to: &output)
        }
        
        Swift.print(message, separator: "\t\t\t", terminator: "\n")
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Logger.info("didRegisterForRemoteNotificationsWithDeviceToken")
        
    }
    
    func userNotificationCenter( _ center: UNUserNotificationCenter,
                                 didReceive response: UNNotificationResponse,
                                 withCompletionHandler completionHandler: @escaping () -> Void) {
        Logger.info("Notification while the app is in foreground with UNUserNotificationCenterDelegate:: [didReceive]: UNNotificationResponse")
        Logger.info("Response:", response)
        Logger.info("Info:", response.notification.request.content.userInfo)
        
        
        Logger.info("UIApplication.shared.applicationState", UIApplication.shared.applicationState.rawValue)
        if UIApplication.shared.applicationState == .background {
            scheduleAppAutoBackup()
        }
      
        
        
        
        
        completionHandler()
    }
    
    func userNotificationCenter( _ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        Logger.info("Es una notificacion remota, con la app activa, debe mostrar Notificacion solo si no es interna")
        Logger.info(notification.debugDescription)
        completionHandler([.banner, .sound])
    }
}


private struct FileHandlerOutputStream: TextOutputStream {
    private let fileHandle: FileHandle
    let encoding: String.Encoding

    init(_ fileHandle: FileHandle, encoding: String.Encoding = .utf8) {
        self.fileHandle = fileHandle
        self.encoding = encoding
    }

    mutating func write(_ string: String) {
        if let data = string.data(using: encoding) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
        }
    }

}

