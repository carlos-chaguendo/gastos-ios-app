//
//  ExportCSVView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 26/05/21.
//

import SwiftUI

struct ExportCSVView: View {
    
    @State private var start = Date()
    @State private var end = Date()
    @ObservedObject private var activity = ActivityView.Model()
    
    var body: some View {
        VStack(alignment: .leading) {
            Row(
                title: "Start date",
                content: DatePicker("", selection: $start, displayedComponents: .date)
                    .accentColor(Colors.primary)
            )
            Row(
                title: "End date",
                content: DatePicker("", selection: $end, displayedComponents: .date)
                    .accentColor(Colors.primary)
            )
            Button("Export CSV") {
                let url = Service.exportAsCSV(between: start, and: end)
                self.activity.url = url
                self.activity.isPresented = true
                
            }.foregroundColor(Colors.primary)
            
            ModalView(isPresented: $activity.isPresented) {
                ActivityView(url: activity.url!)
            }
            
            Spacer()
        }
        .padding()
        .background(Colors.background)
        .onAppear {
            self.start = Date().withStart(of: .month)
        }
    }
    
    
    func Row<Content: View>(title: LocalizedStringKey, content: Content) -> some View {
        VStack(spacing: 20) {
            HStack {
                Text(title)
                    .font(.body)
                    .foregroundColor(Colors.title)
                Spacer()
                content
            }
            Color.gray.frame(height: 1).opacity(0.2)
        }.frame(height: 60, alignment: .leading)
    }
}

struct ExportCSVView_Previews: PreviewProvider {
    static var previews: some View {
        ExportCSVView()
    }
}
