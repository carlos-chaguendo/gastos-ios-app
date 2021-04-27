//
//  Backup.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 16/04/21.
//

import Foundation
import RealmSwift
import Combine
import CoreServices

class BackupService {
    
    public var cancellables = Set<AnyCancellable>()
    
    
    
    private func downloadFile(fileURL: URL, for query: NSMetadataQuery, subject: PassthroughSubject<Double, NSError>) {
        
        let fileName = fileURL.lastPathComponent
        
        guard
            let fileItem = query.resultsFor(fileName: fileName),
            let fileItemURL = fileItem.value(forAttribute: NSMetadataItemURLKey) as? URL
        else {
            subject.send(0)
            return
        }
        
        do {
            try FileManager.default.startDownloadingUbiquitousItem(at: fileItemURL)
            if let fileDownloaded = fileItem.value(forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey) as? String, fileDownloaded == NSMetadataUbiquitousItemDownloadingStatusCurrent {
                subject.send(100)
                subject.send(completion: .finished)
                
                query.disableUpdates()
                query.operationQueue?.addOperation { query.stop() }
                self.cancellables.removeAll()
                print("Download complete")
                
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    try FileManager.default.removeItem(at: fileURL)
                }
                try FileManager.default.copyItem(at: fileItemURL, to: fileURL)
                
                
                
            } else if let error = fileItem.value(forAttribute: NSMetadataUbiquitousItemDownloadingErrorKey) as? NSError {
                print("download error---", error.localizedDescription)
                subject.send(completion: .failure(error))
            } else {
                if let keyProgress = fileItem.value(forAttribute: NSMetadataUbiquitousItemPercentDownloadedKey) as? Double {
                    print("File downloaded percent ---", keyProgress)
                    subject.send(keyProgress)
                }
            }
        } catch {
            print("Manager error---", error.localizedDescription)
            subject.send(completion: .failure(error as NSError))
        }
    }
    
    
    func getBackup(named fileName: String, fileURL: URL) -> AnyPublisher<Double, NSError> {
        
        guard let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
            let error = NSError(domain: "upload", code: 1, userInfo: [NSLocalizedDescriptionKey : " The App Not Have Access to iCloud"])
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        //let fileName = fileURL.lastPathComponent
        let query = NSMetadataQuery.init()
        query.operationQueue = .main
        query.searchScopes = [NSMetadataQueryUbiquitousDataScope]
        query.predicate = NSPredicate(format: "%K LIKE %@", NSMetadataItemFSNameKey, fileName)
        query.operationQueue?.addOperation {
            query.start()
            query.enableUpdates()
        }
        
        let subject = PassthroughSubject<Double, NSError>()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSMetadataQueryDidStartGathering, object: query, queue: query.operationQueue) { (notification) in
            self.downloadFile(fileURL: fileURL, for: query, subject: subject)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSMetadataQueryGatheringProgress, object: query, queue: query.operationQueue) { (notification) in
            self.downloadFile(fileURL: fileURL, for: query, subject: subject)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSMetadataQueryDidUpdate, object: query, queue: query.operationQueue) { (notification) in
            self.downloadFile(fileURL: fileURL, for: query, subject: subject)
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    /// Busca un backup
    /// - Parameter fileName: Nombre del archivo
    /// - Returns:
    func searchBackup(fileName: String) -> AnyPublisher<NSMetadataItem, NSError> {
        return Deferred {
            Future<NSMetadataItem, NSError> { seal in
                Logger.info("Buscando...", fileName)
                let query = NSMetadataQuery.init()
                query.operationQueue = .main
                query.searchScopes = [NSMetadataQueryUbiquitousDataScope]
                query.predicate = NSPredicate(format: "%K LIKE %@", NSMetadataItemFSNameKey, fileName)
        
                NotificationCenter.default.addObserver(forName: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: query, queue: query.operationQueue) { (notification) in
                    defer {
                        query.disableUpdates()
                        query.operationQueue?.addOperation { query.stop() }
                        self.cancellables.removeAll()
                    }

                    guard let fileItem = query.resultsFor(fileName: fileName) else {
                        seal(Result.failure(NSError(domain: "backup", code: 1, userInfo: [NSLocalizedDescriptionKey: "Not found '\(fileName)'"])))
                        return
                    }
         
                    seal(Result.success(fileItem))
                }
                
                query.operationQueue?.addOperation {
                    query.start()
                    query.enableUpdates()
                }
                
                
            }
        }.eraseToAnyPublisher()
    }
    
    
    
    
    
    /// Guarda un archivo en icloud
    /// - Parameter fileURL: URl del archivo local
    /// - Returns: Publisher con el porcentaje de avance
    func startBackup(fileURL: URL) -> AnyPublisher<Double, NSError> {
        
        guard let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
            let error = NSError(domain: "upload", code: 1, userInfo: [NSLocalizedDescriptionKey : " The App Not Have Access to iCloud"])
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        let fileName = fileURL.lastPathComponent
        let backupFileURL = containerURL.appendingPathComponent(fileURL.lastPathComponent)
        
        
        Logger.info("Save:", fileName)
        Logger.info("Into:", backupFileURL)
        
        let query = NSMetadataQuery.init()
        query.operationQueue = .main
        query.searchScopes = [NSMetadataQueryUbiquitousDataScope]
        query.predicate = NSPredicate(format: "%K LIKE %@", NSMetadataItemFSNameKey, fileName)
        
        do {
            if let size = try FileManager.default.attributesOfItem(atPath: fileURL.path)[FileAttributeKey.size] {
                Logger.info("size: ",   ByteCountFormatter().string(for: size))
            }
            
            if !FileManager.default.fileExists(atPath: containerURL.path) {
                try FileManager.default.createDirectory(at: containerURL, withIntermediateDirectories: true, attributes: nil)
            }
            
            if FileManager.default.fileExists(atPath: backupFileURL.path) {
                try FileManager.default.removeItem(at: backupFileURL)
            }
            try FileManager.default.copyItem(at: fileURL, to: backupFileURL)
            
        } catch {
            return Fail(error: error as NSError).eraseToAnyPublisher()
        }
        
        query.operationQueue?.addOperation({ [weak query] in
            query?.start()
            query?.enableUpdates()
        })
        
        let subject = PassthroughSubject<Double, NSError>()
        Publishers.icloudFileUploadUpdate(for: query)
            .sink { userinfo in
                guard
                    let fileItem = query.resultsFor(fileName: fileName),
                    let fileItemURL = fileItem.value(forAttribute: NSMetadataItemURLKey) as? URL
                else {
                    subject.send(0)
                    return
                }
                
                
                let fileValues = try? fileItemURL.resourceValues(forKeys: [URLResourceKey.ubiquitousItemIsUploadingKey])
                
                if let fileUploaded = fileItem.value(forAttribute: NSMetadataUbiquitousItemIsUploadedKey) as? Bool, fileUploaded == true, fileValues?.ubiquitousItemIsUploading == false {
                    print("backup upload complete")
                    subject.send(100)
                    subject.send(completion: .finished)
                    
                    
                    /// Crear el registro en la base de datos local
                    query.disableUpdates()
                    query.operationQueue?.addOperation {
                        query.stop()
                    }
                    self.cancellables.removeAll()
                    
                } else if let error = fileValues?.ubiquitousItemUploadingError {
                    print("upload error---", error.localizedDescription)
                    subject.send(completion: .failure(error))
                    
                } else {
                    
                    /// solo se actualiza para los iyems que se estan subiendo
                    /// para lositems eliminando size == nil
                    guard let size = fileItem.value(forAttribute: "BRMetadataUbiquitousItemUploadingSizeKey") as? Double else {
                        return
                    }
                    
                    if let fileProgress = fileItem.value(forAttribute: NSMetadataUbiquitousItemPercentUploadedKey) as? Double {
                        print("uploaded percent \(size)---", fileProgress)
                        subject.send(fileProgress)
                    }
                }
                
            }.store(in: &cancellables)
        
        return subject.eraseToAnyPublisher()
        
    }
}

extension Publishers {
    
    static func icloudFileUploadUpdate(for query: NSMetadataQuery) -> AnyPublisher<[AnyHashable: Any], Never> {
        let a = NotificationCenter.default.publisher(for: NSNotification.Name.NSMetadataQueryDidStartGathering, object: query).compactMap { $0.userInfo}
        let b = NotificationCenter.default.publisher(for: NSNotification.Name.NSMetadataQueryGatheringProgress, object: query).compactMap { $0.userInfo}
        let c = NotificationCenter.default.publisher(for: NSNotification.Name.NSMetadataQueryDidUpdate, object: query).compactMap { $0.userInfo }
        return MergeMany(a, b, c).eraseToAnyPublisher()
    }
    
    
    
}


extension NSMetadataQuery {
    
    func resultsFor(fileName name: String) -> NSMetadataItem? {
        results
            .compactMap { $0 as? NSMetadataItem }
            .first {   $0.value(forAttribute: NSMetadataItemFSNameKey) as? String == name }
    }
    
}
