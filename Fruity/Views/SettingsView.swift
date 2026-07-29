import SwiftUI

struct SettingsView: View {
    @AppStorage("fruityUsername") private var username: String = "Fruit Friend"
    @AppStorage("fruityNotificationsEnabled") private var notificationsEnabled = false
    @AppStorage("fruityReminderHour") private var reminderHour = 18
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    TextField("Display name", text: $username)
                }

                Section {
                    Toggle("Daily fruit nudge", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { _, isOn in handleToggle(isOn) }
                    if notificationsEnabled {
                        Stepper("Remind me at \(reminderHour):00", value: $reminderHour, in: 6...22)
                            .onChange(of: reminderHour) { _, newHour in
                                NotificationManager.scheduleReminder(hour: newHour)
                            }
                    }
                } header: {
                    Text("Reminders")
                } footer: {
                    Text("A gentle daily nudge to log or discover a fruit. This is a fixed-time reminder, not a smart 'you haven't logged in a while' alert — that would need a backend to track properly.")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func handleToggle(_ isOn: Bool) {
        if isOn {
            Task {
                let granted = await NotificationManager.requestAuthorization()
                if granted {
                    NotificationManager.scheduleReminder(hour: reminderHour)
                } else {
                    notificationsEnabled = false
                }
            }
        } else {
            NotificationManager.cancelReminder()
        }
    }
}
