//
//  DailyReminderView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 23/04/21.
//

import SwiftUI

struct DailyReminderView: View {

    @State private var date = Date()
    @State private var nextFireDate = ""
    @AppStorage("DailyReminderView.includeSound") private var includeSound = true
    @AppStorage("DailyReminderView.message") private var message = "Introducir las transacciones del dia de hoy"
    @AppStorage("DailyReminderView.date") private var appDailyDate = ""

    private let df = DateFormatter()
        .set(\.dateStyle, .full)
        .set(\.timeStyle, .full)

    var body: some View {
        VStack(alignment: .leading) {
            Row(
                title: "Sound",
                content: Toggle("", isOn: $includeSound).accentColor(Colors.primary)
                    .toggleStyle(SwitchToggleStyle(tint: Color(Colors.primary)))
            )

            Row(
                title: "Remember me at",
                content: DatePicker("", selection: $date, displayedComponents: .hourAndMinute)
                    .datePickerStyle(GraphicalDatePickerStyle())
            )

            VStack(spacing: 20) {
                TextField("Introducir las transacciones del dia de hoy", text: $message)
                Color.gray.frame(height: 1).opacity(0.2)
            }.frame(height: 60, alignment: .center)

            if !nextFireDate.isEmpty {
                Text(nextFireDate)
                    .font(.caption)
                    .foregroundColor(Colors.subtitle)
            }

            Spacer()
        }
        .padding()
        .background(Colors.background)
        .onAppear {
            self.date = df.date(from: appDailyDate) ?? Date()
        }.onChange(of: date) { newDate in
            let components = Calendar.gregorian.dateComponents([.hour, .minute], from: newDate)
            let triger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            guard let next = triger.nextTriggerDate() else { return }
            nextFireDate = df.string(from: next)
        }.onDisappear {

            var components = DateComponents()
            components.hour = Calendar.gregorian.component(.hour, from: date)
            components.minute = Calendar.gregorian.component(.minute, from: date)

            let center = UNUserNotificationCenter.current()

            let request = UNNotificationRequest(
                identifier: "daily-remember",
                content: UNMutableNotificationContent()
                    .set(\.sound, includeSound ? UNNotificationSound.default : nil)
                    .set(\.categoryIdentifier, NotificationsCategory.dailyReminder.rawValue)
                    .set(\.body, message),
                trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            )

            center.removePendingNotificationRequests(withIdentifiers: ["daily-remember"])
            center.add(request) { error in
                if let error = error {
                    Logger.info("Errpr", error)
                } else {
                    Logger.info("Recordtoria agregado")
                }
            }

            /// Se fija en los defaults para las futuras configuraciones
            appDailyDate = df.string(from: date)

            center.getPendingNotificationRequests { requests in
                Logger.info("requests ", requests.count)
            }

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

struct DailyReminderView_Previews: PreviewProvider {
    static var previews: some View {
        DailyReminderView()
    }
}
