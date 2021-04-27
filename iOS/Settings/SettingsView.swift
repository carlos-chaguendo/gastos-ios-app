//
//  SettingsView.swift
//  Gastos (iOS)
//
//  Created by Carlos Andres Chaguendo Sanchez on 23/04/21.
//

import SwiftUI

struct SettingsView: View, WithRows {
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {

                Row(title: "Backup copy", destination: iCloudBackupView())
                Row(title: "Daily reminder", destination: DailyReminderView())

                Spacer()
            }.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .background(Colors.background)
            .navigationBarTitle("Settings", displayMode: .inline)
        }

    }

}

protocol WithRows {

}

extension WithRows {

    func Row<Destination: View>(title: LocalizedStringKey, destination: Destination) -> some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 20) {
                HStack {
                    Text(title)
                        .font(.body)

                        .foregroundColor(Colors.title)

                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                // Spacer()
                Color.gray.frame(height: 1).opacity(0.2)
            }

        }
        .frame(height: 60, alignment: .center)
        // .background(.yellow)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
