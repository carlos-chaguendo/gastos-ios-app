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
    
    private init() { }

    private static func downloadFile(destination fileURL: URL, for query: NSMetadataQuery, subject: PassthroughSubject<Double, NSError>) {

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
            if let fileDownloaded = fileItem.value(forAttribute: NSMetadataUbiquitousItemDownloadingStatusKey) as? String,
               fileDownloaded == NSMetadataUbiquitousItemDownloadingStatusCurrent {
                subject.send(100)
                subject.send(completion: .finished)

                query.disableUpdates()
                query.operationQueue?.addOperation { query.stop() }
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
    
    /// Description
    /// - Parameters:
    ///   - fileName: fileName description
    ///   - destination: fileURL description
    /// - Returns: description
    static func restoreBackup(named fileName: String, destination fileURL: URL) -> AnyPublisher<Double, NSError> {

        // let fileName = fileURL.lastPathComponent
        let query = NSMetadataQuery.init()
        query.operationQueue = .main
        query.searchScopes = [NSMetadataQueryUbiquitousDataScope]
        query.predicate = NSPredicate(format: "%K LIKE %@", NSMetadataItemFSNameKey, fileName)
        query.operationQueue?.addOperation {
            query.start()
            query.enableUpdates()
        }

        let subject = PassthroughSubject<Double, NSError>()
        NotificationCenter.default.addObserver(forName: .NSMetadataQueryDidStartGathering, object: query, queue: query.operationQueue) { _ in
            self.downloadFile(destination: fileURL, for: query, subject: subject)
        }

        NotificationCenter.default.addObserver(forName: .NSMetadataQueryGatheringProgress, object: query, queue: query.operationQueue) { _ in
            self.downloadFile(destination: fileURL, for: query, subject: subject)
        }

        NotificationCenter.default.addObserver(forName: .NSMetadataQueryDidUpdate, object: query, queue: query.operationQueue) { _ in
            self.downloadFile(destination: fileURL, for: query, subject: subject)
        }

        return subject.eraseToAnyPublisher()
    }

    /// Busca un backup
    /// - Parameter fileName: Nombre del archivo
    /// - Returns:
    static func searchBackup(fileName: String) -> AnyPublisher<NSMetadataItem, NSError> {
        return Deferred {
            Future<NSMetadataItem, NSError> { seal in
                
                guard let container = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
                    let error = NSError(domain: "search", code: 1, userInfo: [NSLocalizedDescriptionKey: " The App Not Have Access to iCloud"])
                    seal(.failure(error))
                    return
                }
        
                Logger.info("Buscando...", fileName)
                let query = NSMetadataQuery.init()
                query.operationQueue = .main
                query.searchScopes = [NSMetadataQueryUbiquitousDataScope]
                query.predicate = NSPredicate(format: "%K LIKE %@", NSMetadataItemFSNameKey, fileName)
                
                
                #if DEBUG
                    let fileItemURL = container.appendingPathComponent(fileName)
                    do {
                        try FileManager.default.startDownloadingUbiquitousItem(at: fileItemURL)
                    } catch {
                        seal(.failure(error as NSError))
                    }
                #endif
                

                NotificationCenter.default.addObserver(forName: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: query, queue: query.operationQueue) { (_) in
                    defer {
                        query.disableUpdates()
                        query.operationQueue?.addOperation { query.stop() }
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
    static func startBackup(fileURL: URL, notifyProgress: Bool = true, operation: OperationQueue = .main) -> AnyPublisher<Double, NSError> {

        guard let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
            let error = NSError(domain: "upload", code: 1, userInfo: [NSLocalizedDescriptionKey: " The App Not Have Access to iCloud"])
            return Fail(error: error).eraseToAnyPublisher()
        }

        let fileName = fileURL.lastPathComponent
        let backupFileURL = containerURL.appendingPathComponent(fileURL.lastPathComponent)

        Logger.info("Save:", fileName)
        Logger.info("Into:", backupFileURL)
        Logger.info("operation", operation)

        let query = NSMetadataQuery.init()
        query.operationQueue = operation
        query.searchScopes = [NSMetadataQueryUbiquitousDataScope]
        query.predicate = NSPredicate(format: "%K LIKE %@", NSMetadataItemFSNameKey, fileName)

        do {
            if let size = try FileManager.default.attributesOfItem(atPath: fileURL.path)[FileAttributeKey.size] {
                Logger.info("size: ", ByteCountFormatter().string(for: size))
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
            .receive(on: query.operationQueue!)
            .receive(subscriber: Subscribers.Sink.init { completion in
                /// Nunca se ejecuta, notification center nunca envia el evento completado
                Logger.info("Completion", completion)
            } receiveValue: { _ in
                guard
                    let fileItem = query.resultsFor(fileName: fileName),
                    let fileItemURL = fileItem.url
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

                    DispatchQueue.main.async {
                        Service.registreNewBackup()
                    }

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
            })

        return subject.eraseToAnyPublisher()

    }
}

extension Publishers {

    static func icloudFileUploadUpdate(for query: NSMetadataQuery) -> AnyPublisher<[AnyHashable: Any], Never> {
        let center = NotificationCenter.default
        let start = center.publisher(for: .NSMetadataQueryDidStartGathering, object: query)
        let progress = center.publisher(for: .NSMetadataQueryGatheringProgress, object: query)
        let update = center.publisher(for: .NSMetadataQueryDidUpdate, object: query)
        
        return MergeMany(
            start.compactMap { $0.userInfo},
            progress.compactMap { $0.userInfo},
            update.compactMap { $0.userInfo}
        ).eraseToAnyPublisher()
    }

}

extension NSMetadataQuery {

    func resultsFor(fileName name: String) -> NSMetadataItem? {
        results
            .compactMap { $0 as? NSMetadataItem }
            .first {   $0.value(forAttribute: NSMetadataItemFSNameKey) as? String == name }
    }

}

extension NSMetadataItem {
    
    var isUploaded: Bool? {
        value(forAttribute: NSMetadataUbiquitousItemIsUploadedKey) as? Bool
    }
    
    var url: URL? {
        value(forAttribute: NSMetadataItemURLKey) as? URL
    }
    
}
