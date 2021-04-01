//
//  FileImport.swift
//  Gastos
//
//  Created by Carlos Andres Chaguendo Sanchez on 31/03/21.
//

import SwiftUI
import CoreServices

struct FileImportButton: View {

    
    @State var isDocumentPickerPresented: Bool = false
    
    var body: some View {
        Button("Arkit") {
            self.isDocumentPickerPresented.toggle()
        }
        .sheet(isPresented: $isDocumentPickerPresented) {
            DocumentPickerViewController(type: kUTTypeCommaSeparatedText) { url in
   
                Logger.info("File:", url)
                getCSVData(file: url).forEach {
                    Service.addItem($0)
                }
            }
        }.navigationBarTitle("", displayMode: .inline)
    }
    
    
    func getCSVData(file: URL) -> Array<ExpenseItem> {
        do {
            let df = DateFormatter()
            df.dateFormat = "\"dd/MM/yyyy HH:mm:ss\""
            
            let url = file//Service.realm.configuration.fileURL?.deletingLastPathComponent().appendingPathComponent("DayCost.csv")
            let content = try String(contentsOfFile: url.path)
            let parsedCSV = content.components(
                separatedBy: "\n"
            ).dropFirst().map { line -> ExpenseItem in
               let item = line.components(separatedBy: ",")
                let fehca = item[0]
                let categoria = item[1]
                let nota = item[9].replacingOccurrences(of: "\"", with: "")
                let valor = item[7].replacingOccurrences(of: "\"$ ", with: "").replacingOccurrences(of: "\"", with: "")
                
                return ExpenseItem {
                    $0.title = nota
                    $0.value = Double(valor) ?? 0.0
                    $0.date = df.date(from: fehca)!
                    $0.id =  $0.date.description
                }
            }
            return parsedCSV
        }
        catch {
            return []
        }
    }
    
}
