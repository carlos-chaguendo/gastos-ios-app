//
//  FileImport.swift
//  Gastos
//
//  Created by Carlos Andres Chaguendo Sanchez on 31/03/21.
//

import SwiftUI
import CoreServices
import Combine

struct FileImportButton: View {
    
    
    enum State {
        case forImport
        case withFileURL
        case failure(Error)
    }
    
    @ObservedObject var  viewModel = ViewModel()
    
    var body: some View {
        VStack {
            switch viewModel.state {
            case .forImport:
                PresentLinkView(destination: DocumentPickerViewController(type: kUTTypeCommaSeparatedText) { url in
                    do {
                        try viewModel.readCSV(from: url)
                        
                    } catch {
                        viewModel.state = .failure(error)
                    }
                }) {
                    Text("Import CSV")
                }
                
            case .withFileURL:
        
                ProgressView("\(viewModel.progress.cleanValue) of \(viewModel.numberOfLines.cleanValue)", value: viewModel.progress, total: viewModel.numberOfLines)
                    .foregroundColor(Colors.primary)
                
                
            case .failure(let error):
                
                Text((error as NSError).description)
                
            }
            
            
            
        }.navigationBarTitle("", displayMode: .inline)
    }
    
    
}

extension FileImportButton {
    
    
    class ViewModel: ObservableObject {
        
        let df = DateFormatter()
            .set(\.dateFormat,  "\"dd/MM/yyyy HH:mm:ss\"")
        
        var categoriesByName: [String: Catagory] = [:]
        var walletsByName: [String: Wallet] = [:]
        
        var lines: [String] = []
        
        
        @Published var numberOfLines = 0.0
        @Published var progress = 0.0
        @Published var state = State.forImport
        
        private var cancellable: Cancellable?
        
        func readCSV(from url: URL) throws {
            let content = try String(contentsOfFile: url.path)
            let parsedCSV = content.components(
                separatedBy: "\n"
            )
            
            self.lines = parsedCSV
            self.lines.removeFirst()
            self.numberOfLines = Double(lines.count)
            self.progress = 0.0
            self.state = .withFileURL
            
            loadCategoriesByname()
            loadWallerByname()
            
            
            cancellable = lines.publisher
                .flatMap(maxPublishers: .max(1)) { e in
                    Just(e).delay(for: 0.001, scheduler: RunLoop.main)
                }.sink(receiveCompletion: { _ in
                    self.state = .forImport
                }, receiveValue:  { line in
                    
                    let item = line.components(separatedBy: ",")
                    let fehca = item[0]
                    let categoria = item[1].replacingOccurrences(of: "\"", with: "").capitalized
                    let cuenta = item[2].replacingOccurrences(of: "\"", with: "").capitalized
                    let nota = item[9].replacingOccurrences(of: "\"", with: "").capitalized
                    let valor = item[7].replacingOccurrences(of: "\"$ ", with: "").replacingOccurrences(of: "\"", with: "")
                    
                    let expense = ExpenseItem {
                        $0.title = nota
                        $0.value = Double(valor) ?? 0.0
                        $0.date = self.df.date(from: fehca)!
                        $0.id =  $0.date.description
                        $0.category = self.addCategory(named: categoria)
                        $0.wallet = self.addWallt(named: cuenta)
                    }
                    
                    Service.addItem(expense, notify: false)
                    self.progress += 1.0
                    print("progres \(self.progress)")
                })
        }
        
        func loadCategoriesByname() {
            self.categoriesByName = Service.getAll(Catagory.self)
                .groupBy { $0.name.uppercased() }
                .compactMapValues { $0.first }
        }
        
        func loadWallerByname() {
            self.walletsByName = Service.getAll(Wallet.self)
                .groupBy { $0.name.uppercased() }
                .compactMapValues { $0.first }
        }
        
        /// Description
        /// - Parameter named: named description
        /// - Returns: description
        func addCategory(named: String) -> Catagory {
            
            if let local = categoriesByName[named.uppercased()] {
                return local
            }
            
            let new = Service.addCategory(Catagory {
                $0.name = named
            })
            
            categoriesByName[new.name.uppercased()] = new
            return new
        }
        
        /// Description
        /// - Parameter named: named description
        /// - Returns: description
        func addWallt(named: String) -> Wallet {
            if let local = walletsByName[named.uppercased()] {
                return local
            }
            
            let new = Service.addWallet(Wallet {
                $0.name = named
            })
            
            walletsByName[new.name.uppercased()] = new
            return new
        }
        
        
    }
    
}
