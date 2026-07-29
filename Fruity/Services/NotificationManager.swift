import Foundation
import UserNotifications

/// Purely local notifications — no backend, no push server. Schedules a
/// repeating daily reminder at a user-chosen time.
enum NotificationManager {
    private static let reminderID = "fruity.dailyReminder"

    static func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func scheduleReminder(hour: Int, minute: Int = 0) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [reminderID])

        let content = UNMutableNotificationContent()
        content.title = "🍓 Time for a new fruit?"
        content.body = randomPrompt()
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: reminderID, content: content, trigger: trigger)
        center.add(request)
    }

    static func cancelReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminderID])
    }

    private static func randomPrompt() -> String {
        [
            "Explore something new on the Discover tab today.",
            "Your passport is waiting for its next stamp 🌍",
            "Tried anything exotic lately? Log it before you forget!",
            "There's a whole world of fruit you haven't tasted yet."
        ].randomElement()!
    }
}
