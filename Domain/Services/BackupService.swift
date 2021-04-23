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

    func startBackup(fileURL: URL) -> AnyPublisher<Double, NSError> {

        let subject = PassthroughSubject<Double, NSError>()
        
        guard let containerURL = FileManager.default.url(forUbiquityContainerIdentifier: nil) else {
            subject.send(completion: .failure(NSError(domain: "upload", code: 1, userInfo: [NSLocalizedFailureErrorKey : "iCloud is disabled"])))
            return subject.eraseToAnyPublisher()
        }
        
        let fileName = fileURL.lastPathComponent
        let backupFileURL = containerURL.appendingPathComponent(fileURL.lastPathComponent)
        
        
        
        Logger.info("Save:", fileName)
        Logger.info("Into:", backupFileURL)
        
        let query = NSMetadataQuery.init()
        query.operationQueue = .main
        query.searchScopes = [NSMetadataQueryUbiquitousDataScope]
        
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
            subject.send(completion: .failure(error as NSError))
        }
        
        
        query.predicate = NSPredicate(format: "%K LIKE %@", NSMetadataItemFSNameKey, fileName)
        query.operationQueue?.addOperation({ [weak query] in
            query?.start()
            query?.enableUpdates()
        })
        
        Publishers.icloudFileUploadUpdate.sink {
            
            guard
                let fileItem = query.resultsFor(fileName: fileName),
                let fileItemURL = fileItem.value(forAttribute: NSMetadataItemURLKey) as? URL
            else {
                return
            }
            

            let fileValues = try? fileItemURL.resourceValues(forKeys: [URLResourceKey.ubiquitousItemIsUploadingKey])
            
            
            if let fileUploaded = fileItem.value(forAttribute: NSMetadataUbiquitousItemIsUploadedKey) as? Bool, fileUploaded == true, fileValues?.ubiquitousItemIsUploading == false {
                print("backup upload complete")
                
                subject.send(1)
                subject.send(completion: .finished)
                
            } else if let error = fileValues?.ubiquitousItemUploadingError {
                print("upload error---", error.localizedDescription)
                subject.send(completion: .failure(error))

            } else {
                if let fileProgress = fileItem.value(forAttribute: NSMetadataUbiquitousItemPercentUploadedKey) as? Double {
                    print("uploaded percent ---", fileProgress)
                    subject.send(fileProgress)
                }
            }

        }.store(in: &cancellables)
        return subject.eraseToAnyPublisher()
    }
    
    

}

extension Publishers {
    
    static var icloudFileUploadUpdate: AnyPublisher<Void, Never> {
        let a = NotificationCenter.default.publisher(for: NSNotification.Name.NSMetadataQueryDidStartGathering)
        let c = NotificationCenter.default.publisher(for: NSNotification.Name.NSMetadataQueryDidUpdate)
        return MergeMany(a, c).asVoid().eraseToAnyPublisher()
          
    }
    
}


extension NSMetadataQuery {
    
    func resultsFor(fileName name: String) -> NSMetadataItem? {
        results
            .compactMap { $0 as? NSMetadataItem }
            .first {   $0.value(forAttribute: NSMetadataItemFSNameKey) as? String == name }
    }
    
}
