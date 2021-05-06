//
//  IcloudBackupView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 23/04/21.
//

import SwiftUI
import Combine
import RealmSwift

struct iCloudBackupView: View {
    
    enum Status {
        case uploading
        case failure(NSError)
        case none
    }
    
    let backup = BackupService()
    
    @State public var cancellables = Set<AnyCancellable>()
    @State private var status = Status.none
    @State private var progress = 0.0
    @State private var lastBackup: Date?
    
    private var fileSize: Double!
    private let bf = ByteCountFormatter()
    private let df = DateFormatter()
        .set(\.dateStyle, .full)
        .set(\.timeStyle, .short)
    
    init() {
        
        let file = Realm.Configuration.defaultConfiguration.fileURL!
        let calculateSize = try? FileManager.default.attributesOfItem(atPath: file.path)[FileAttributeKey.size] as? Double
        self.fileSize = calculateSize ?? 0.0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            VStack(alignment: .leading) {
                
                Image(systemName: "arrow.counterclockwise.icloud.fill")
                    .font(.title)
                    .foregroundColor(Colors.primary)
                
                Text("Last Backup")
                    .font(.body)
                    .foregroundColor(Colors.title)
                
                Text(df.string(from: lastBackup ?? Date()))
                    .font(.caption)
                    .foregroundColor(Colors.subtitle)
                    .padding(.bottom, 10)
                    .onAppear {
                        lastBackup = Service.getApplicationData().lastBackup
                    }
                
                Text("_icloud_create_backup_description_")
                    .font(.body)
                    .foregroundColor(Colors.title)
            }
            
            switch self.status {
            case .uploading:
                VStack(alignment: .leading) {
                    Text("Realizando copia ...")
                        .font(.body)
                        .foregroundColor(Colors.title)
                    
                    Text("cargando: \( bf.string(for: (fileSize * progress)/100) ?? "" ) de \(bf.string(for: fileSize) ?? "") (\(progress.cleanValue)%)")
                        .font(.caption)
                        .foregroundColor(Colors.subtitle)
                        .padding(.bottom, 10)
                }
                
            case .failure(let error):
                
                Text(error.localizedFailureReason ?? error.localizedDescription )
                    .font(.body)
                    .foregroundColor(.red)
                
            case .none:
                Button {
                    self.status = .uploading
                    self.progress = 0
                    
                    backup.startBackup(fileURL: Service.fileURL)
                        .sink { completion in
                            Logger.info("completion", completion)
                            switch completion {
                            case .finished:
                                self.status = .none
                                self.lastBackup = Service.getApplicationData().lastBackup ?? Date()
                            case .failure(let error):  self.status = .failure(error)
                            }
                        } receiveValue: { progress in
                            Logger.info("progreso", progress)
                            self.progress = progress.rounded(toPlaces: 2)
                        }.store(in: &cancellables)
                    
                } label: {
                    (Text("Create a backup copy") + Text(" \(bf.string(for: fileSize) ?? "")"))
                }.foregroundColor(Colors.primary)
                
                
            }
            Spacer()
            Divider()
        }
        .padding()
        .navigationTitle("Backup copy")
        .background(Colors.background)
    }
    
}

struct IcloudBackupView_Previews: PreviewProvider {
    static var previews: some View {
        iCloudBackupView()
    }
}
