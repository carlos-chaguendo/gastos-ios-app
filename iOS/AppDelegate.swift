//
//  AppDelegate.swift
//  Gastos
//
//  Created by Carlos Andres Chaguendo Sanchez on 27/04/21.
//

import UIKit
import RealmSwift
import BackgroundTasks
import Combine

class AppDelegate: NSObject, UIApplicationDelegate {
    public var cancellables = Set<AnyCancellable>()
    
    private let df = DateFormatter()
        .set(\.dateStyle, .short)
        .set(\.timeStyle, .short)
    
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
    
    var now: String {
        df.string(from: Date() )
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.pprint("Did EnterBackground )")
        scheduleAppAutoBackup()
    }
    
    /// https://developer.apple.com/documentation/backgroundtasks/starting_and_terminating_tasks_during_development
    func scheduleAppAutoBackup() {
        pprint("scheduleAppAutoBackup ")
    
        BGTaskScheduler.shared.getPendingTaskRequests { requests in
            guard requests.contains(where: { $0.identifier == "com.mayorgafirm.Gastos.backup"}) == false else {
                self.pprint("Ya esta registrado")
                
                requests.forEach {
                    self.pprint("Netx \(self.df.string(from: $0.earliestBeginDate!))")
                }
                
                return
            }
            
            do {
                let request = BGProcessingTaskRequest(identifier: "com.mayorgafirm.Gastos.backup")
                request.earliestBeginDate = Date().withEnd(of: .day)
                try BGTaskScheduler.shared.submit(request)
                self.pprint("earliest \(self.df.string(from: request.earliestBeginDate!))")
            } catch {
                self.pprint("Could not schedule app refresh: \(error)")
            }
        }
    }
    
    func handleAppBackUp(task: BGProcessingTask) {
        pprint(" Iniciando backup automatico")
        scheduleAppAutoBackup()
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        BackupService.startBackup(fileURL: Service.fileURL, notifyProgress: true, operation: queue)
            .sink { completion in
                self.pprint(" completion \(completion)")
                switch completion {
                case .finished:
                    self.pprint(" Termino la operacion")
                    task.setTaskCompleted(success: true)
                    
                case .failure(let error):
                    self.pprint(" Termino la operacion \(error.description)")
                    task.setTaskCompleted(success: false)
                    
                }
            } receiveValue: { progress in
                self.pprint(" progreso \( progress)")
                if progress >= 100 {
                    task.setTaskCompleted(success: true)
                }
            }.store(in: &self.cancellables)
        
        // After all operations are cancelled, the completion block below is called to set the task to complete.
        task.expirationHandler = {
            self.pprint(" Expiration")
            self.cancellables.forEach { $0.cancel() }
            queue.cancelAllOperations()
        }
    }
    
    func pprint(_ message: String) {
        if var output = AppDelegate.file {
            Swift.print("\(now) \(message)", separator: "\t\t\t", terminator: "\n", to: &output)
        }
        
        Swift.print("\(now) \(message)", separator: "\t\t\t", terminator: "\n")
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
