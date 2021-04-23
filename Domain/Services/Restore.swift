//
//  Restore.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 16/04/21.
//

import Foundation
import RealmSwift

class Restore: NSObject {
    
    var query: NSMetadataQuery!

    override init() {
        super.init()
        
        initialiseQuery()
        addNotificationObservers()
    }
    
    func initialiseQuery() {
        
        query = NSMetadataQuery.init()
        query.operationQueue = .main
        query.searchScopes = [NSMetadataQueryUbiquitousDataScope]
        query.predicate = NSPredicate(format: "%K LIKE %@", NSMetadataItemFSNameKey, "default.realm")
    }
    
    func addNotificationObservers() {
                        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSMetadataQueryDidStartGathering, object: query, queue: query.operationQueue) { (notification) in
            self.processCloudFiles()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSMetadataQueryGatheringProgress, object: query, queue: query.operationQueue) { (notification) in
            self.processCloudFiles()
        }

        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSMetadataQueryDidUpdate, object: query, queue: query.operationQueue) { (notification) in
            self.processCloudFiles()
        }
    }
    
    @objc func processCloudFiles() {
           
           if query.results.count == 0 { return }
           var fileItem: NSMetadataItem?
           var fileURL: URL?
           
           for item in query.results {
               
               guard let item = item as? NSMetadataItem else { continue }
            
            print("Resultados")
            
            item.attributes.forEach { attr in
               print("\t\t\(attr) :::" , item.value(forAttribute: attr))
            }
            
               guard let fileItemURL = item.value(forAttribute: NSMetadataItemURLKey) as? URL else { continue }
               if fileItemURL.lastPathComponent.contains("default.realm") {
                   fileItem = item
                   fileURL = fileItemURL
               }
           }
        
        guard let fileURL2 = fileURL else {
            return
        }
           
           try? FileManager.default.startDownloadingUbiquitousItem(at: fileURL2)
           
           if let fileDownloaded = fileItem?.value(forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey) as? String, fileDownloaded == NSMetadataUbiquitousItemDownloadingStatusCurrent {
               
               query.disableUpdates()
               query.operationQueue?.addOperation({ [weak self] in
                   self?.query.stop()
               })
               print("Download complete")
            
            
            try! FileManager.default.removeItem(at:  Realm.Configuration.defaultConfiguration.fileURL!)
            try! FileManager.default.copyItem(at: fileURL2, to: Realm.Configuration.defaultConfiguration.fileURL!)
            
           
           } else if let error = fileItem?.value(forAttribute: NSMetadataUbiquitousItemDownloadingErrorKey) as? NSError {
               print(error.localizedDescription)
           } else {
               if let keyProgress = fileItem?.value(forAttribute: NSMetadataUbiquitousItemPercentDownloadedKey) as? Double {
                   print("File downloaded percent ---", keyProgress)
               }
           }
       }
    
    func getBackup() {
         
         query.operationQueue?.addOperation({ [weak self] in
             self?.query.start()
             self?.query.enableUpdates()
         })
     }
}
