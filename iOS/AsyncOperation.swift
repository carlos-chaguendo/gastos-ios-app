//
//  AsyncOperation.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 5/05/21.
//

import Foundation
import Combine

class AsyncOperation: Operation {
    
    private let lockQueue = DispatchQueue(label: "com.swiftlee.asyncoperation", attributes: .concurrent)
    
    override var isAsynchronous: Bool {
        return true
    }
    
    private var _isExecuting: Bool = false
    override private(set) var isExecuting: Bool {
        get {
            return lockQueue.sync { () -> Bool in
                return _isExecuting
            }
        }
        set {
            willChangeValue(forKey: "isExecuting")
            lockQueue.sync(flags: [.barrier]) {
                _isExecuting = newValue
            }
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    private var _isFinished: Bool = false
    override private(set) var isFinished: Bool {
        get {
            return lockQueue.sync { () -> Bool in
                return _isFinished
            }
        }
        set {
            willChangeValue(forKey: "isFinished")
            lockQueue.sync(flags: [.barrier]) {
                _isFinished = newValue
            }
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override func start() {
        print("Starting")
        guard !isCancelled else {
            finish()
            return
        }
        
        isFinished = false
        isExecuting = true
        main()
    }
    
    override func main() {
        fatalError("Subclasses must implement `main` without overriding super.")
    }
    
    func finish() {
        isExecuting = false
        isFinished = true
    }
}


final class FileUploadOperation: AsyncOperation {
    
    public var cancellables = Set<AnyCancellable>()
    
    private var log: (String)-> Void
    private var operation: OperationQueue
    
    init(log: @escaping (String)-> Void, operation: OperationQueue) {
        self.log = log
        self.operation = operation
        super.init()
    }
    
    override func main() {
        
//        BackupService()
//            .searchBackup(fileName: "default.realm")
//            .sink { completion in
//                print("comple", completion)
//
//                self.finish()
//
//            } receiveValue: { metadata in
//                Logger.info("Listo para descargar")
//            }.store(in: &cancellables)
        
        BackupService().startBackup(fileURL: Service.fileURL, notifyProgress: false, operation: operation)
            .sink { completion in
                
                switch completion {
                case .finished:
                    self.log("backup  correcto")
                case .failure(let error):
                    self.log("backup  ecrror :\(error)")
                }
                
                self.finish()
                
            } receiveValue: { progress in
                self.log("backup  progress :\(progress)")
            }.store(in: &cancellables)
    }
    
    override func cancel() {
        cancellables.forEach { $0.cancel() }
        super.cancel()
    }
}
