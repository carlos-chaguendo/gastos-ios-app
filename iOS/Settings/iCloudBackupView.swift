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
    
    private var fileSize: Double!
    private let bf = ByteCountFormatter()
    
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
                
                Text("Ultima copia")
                    .font(.body)
                    .foregroundColor(Colors.title)
                
                Text("16 abril 2020 • 30 MB")
                    .font(.caption)
                    .foregroundColor(Colors.subtitle)
                    .padding(.bottom, 10)
                
                
                Text("Haz una copia de seguridad en iCloud de tus gastos, de modo que si pierdes tu iPhone o lo cambias por uno nuevo, esta información esta segura. Podrás restaurar tu historial de gastos una vez reinstales la aplicación")
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
                Button("Respaladar Ahora (\(bf.string(for: fileSize) ?? ""))") {
                    self.status = .uploading
                    self.progress = 0
                    
                    backup.startBackup(fileURL: Realm.Configuration.defaultConfiguration.fileURL!)
                        .sink(
                            receiveCompletion: { completion in
                                Logger.info("completion", completion)
                            switch completion {
                            case .finished: self.status = .none
                            case .failure(let error):  self.status = .failure(error)
                            }
                        }, receiveValue: { progress in
                            Logger.info("progreso", progress)
                            self.progress = progress.rounded(toPlaces: 2)
                        }).store(in: &cancellables)
                }
                //.buttonStyle(ButtonStyleFormLarge())
                
            }
            Spacer()
            Divider()
        }
        .padding()
        .navigationTitle("Backup copy")
    }
    
 
}


struct IcloudBackupView_Previews: PreviewProvider {
    static var previews: some View {
        iCloudBackupView()
    }
}
