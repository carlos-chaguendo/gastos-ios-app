//
//  DebugView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 20/05/21.
//
import SwiftUI
import CloudKit
import BackgroundTasks

struct DebugView: View {
    
    let  number = Int.random(in: 0..<100)
    
    @State var updateView = 0
    
    @State private var bgColor = Color.red
    
    @State private var notifications: [UNNotificationRequest] = []
    
    @State private var tasks: [BGTaskRequest] = []
    
    private let df = DateFormatter()
        .set(\.dateStyle, .full)
        .set(\.timeStyle, .full)
    
    @State var selected = 1
    
    @State var isDocumentPreviewPresented: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {

                Text("has \(number)")
                Text("u \(Int.random(in: 0..<100))")
                Text("updateView \(updateView)")
                    .onAppear {
                        self.updateView += 1
                    }
                
                FileImportButton()
                    .cardView()
                
                Button("Save record") {
                    let record = CKRecord(recordType: "ToDoItem")
                    record.setValuesForKeys([
                        "title": "Get apples \(Int.random(in: 0...100))",
                        "dueDate": DateComponents(
                            calendar: Calendar.current,
                            year: 2019,
                            month: 10,
                            day: 28).date!,
                        "isCompleted": false // Stored as Int(64)
                    ])
                    
                    CKContainer.default().privateCloudDatabase.save(record) { record, error in
                        Logger.info("Record ", record)
                        Logger.info("Error", error)
                    }
                }
                
                Button("clears Log") {
                    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("log.txt")
                    
                    try? FileManager.default.removeItem(at: url)
                    
                }.foregroundColor(.systemRed)
                
                Button("Open Log") {
                    self.isDocumentPreviewPresented.toggle()
                }.sheet(isPresented: $isDocumentPreviewPresented) {
                    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("log.txt")
                    NavigationView {
                        DocumentInteractionController(url: url)
                            .navigationTitle("log.txt")
                    }
                }
                
                ForEach(notifications, id: \.identifier) { request in
                    
                    VStack {
                        Text(request.content.body)
                        
                        if let calendar =  request.trigger as? UNCalendarNotificationTrigger, let date = calendar.nextTriggerDate() {
                            Text(df.string(from: date))
                        }
                    }
                    
                }

//
                SegmentedView([1, 2, 3, 4, 5, 6], selected: $selected) { e in
                    Text("\(e)")

                }.padding(.vertical)
                
            }
        }.background(Colors.background)
        .onAppear {
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                Logger.info("requests ", requests.count)
                
                notifications = requests
            }
            
            BGTaskScheduler.shared.getPendingTaskRequests { reuqest in
                Logger.info("tasks ", reuqest.count)
                tasks = reuqest
            }
        }
        
    }
}
