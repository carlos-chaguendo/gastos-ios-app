//
//  iCloudRestoreView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 23/04/21.
//

import SwiftUI
import RealmSwift
import Combine
import CoreServices

struct iCloudRestoreView: View {
    
    enum Status {
        case searching
        case downloadig
        case failure(NSError)
        case found
        case restaured
    }
    
    @State private var status = Status.searching
    @State public var cancellables = Set<AnyCancellable>()
    @State private var date: Date! = Date()
    @State private var fileSize: Double! = 0.0
    @State private var progress = 0.0
    @State private var url: URL!
    
    @Binding public var restorationTerminated: Bool
    
    private let bf = ByteCountFormatter()
    private let df = DateFormatter()
        .set(\.dateStyle, .medium)
        .set(\.timeStyle, .medium)
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                
                Image(systemName: "arrow.counterclockwise.icloud.fill")
                    .font(.title)
                    .foregroundColor(Colors.primary)
                
                Text("Restore")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom)
                
                
                switch status {
                case .found, .downloadig :
                    Text(bf.string(for: fileSize) ?? "")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(Colors.title)
                    
                    Text(df.string(from: date))
                        .font(.caption)
                        .foregroundColor(Colors.subtitle)
                        .padding(.bottom, 10)
                    
                    
                    Text("Restaurar tu historial de gastos desde iCloud. Si no lo restauras ahora, no podras hacerlo después")
                        .font(.body)
                        .foregroundColor(Colors.title)
                    
                default: EmptyView()
                }
                
                
                
                switch self.status {
                case .searching:
                    ProgressView()
                    Spacer()
                    
                case .found:
                    Spacer()
                    
                    Button("Restaurar") {
                        self.status = .downloadig
                        self.progress = 0
                        let file = Service.fileURL
                        let backup = self.url.lastPathComponent
                        
                        fistly {
                            BackupService().getBackup(named: backup, fileURL: file)
                        }.sink { completion in
                            self.status = .restaured
                        } receiveValue: { progress in
                            Logger.info("progreso", progress)
                            self.progress = progress.rounded(toPlaces: 2)
                        }.store(in: &cancellables)
                        
                    }
                    .buttonStyle(ButtonStyleFormLarge())
                    .padding(.vertical)
                    
                case .downloadig:
                    
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Descargando copia ...")
                            .font(.body)
                            .foregroundColor(Colors.title)
                        
                        Text("cargando: \( bf.string(for: (fileSize * progress)/100) ?? "" ) de \(bf.string(for: fileSize) ?? "") (\(progress.cleanValue)%)")
                            .font(.caption)
                            .foregroundColor(Colors.subtitle)
                            .padding(.bottom, 10)
                    }
                    
                case .restaured:
                    
                    Text("Informacion restaurada")
                        .font(.body)
                        .foregroundColor(Colors.title)
                    
                    Spacer()
                    Button("Continuar") {
                        self.restorationTerminated = false
                    }
                    .buttonStyle(ButtonStyleFormLarge())
                    .padding(.vertical)
                    
                case .failure(let error):
                    Text(error.localizedFailureReason ?? error.localizedDescription )
                        .font(.body)
                        .foregroundColor(.red)
                }
                
                
                
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .onAppear {
                fistly {
                    BackupService().searchBackup(fileName: "default.realm")
                }
                .delay(for: 2, scheduler: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    print("comple", completion)
                    switch completion {
                    case .finished: self.status = .found
                    case .failure:
                        self.restorationTerminated = false
                    }
                }, receiveValue: { metadata in
                    
                    Logger.info("Listo para descargar")
                    self.date = metadata.value(forKey: "kMDItemFSContentChangeDate") as? Date
                    self.fileSize = metadata.value(forAttribute: "kMDItemFSSize") as? Double ?? 0.0
                    self.status = .found
                    self.url = metadata.value(forAttribute: NSMetadataItemURLKey) as? URL
                    
                }).store(in: &cancellables)
                
                
            }.navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(trailing: Button("Skip") {
                self.restorationTerminated = false
            })
        }
    }
}

struct iCloudRestoreView_Previews: PreviewProvider {
    static var previews: some View {
        iCloudRestoreView(restorationTerminated: .constant(true))
    }
}
