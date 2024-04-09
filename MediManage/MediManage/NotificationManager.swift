import Foundation
import UserNotifications

class NotificationManager {
    static func scheduleNotification(for medication: Medication) {
        guard let timeOfDay = medication.timeOfDay else {
            print("No time specified for medication: \(medication.name)")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Medication Reminder"
        content.body = "It's time to take \(medication.name)."
        content.sound = UNNotificationSound.default

        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: timeOfDay)
        let trigger = UNCalendarNotificationTrigger(dateMatching: timeComponents, repeats: true)

        let identifier = "\(medication.name)-\(medication.dosage)" // Unique identifier
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully for \(medication.name) at \(timeOfDay)")
            }
        }
    }
}

// Sources:
//https://developer.apple.com/documentation/usernotifications
//https://developer.apple.com/documentation/usernotifications/unusernotificationcenterdelegate
//https://developer.apple.com/documentation/usernotifications/unnotificationrequest
//https://developer.apple.com/documentation/usernotifications/unnotificationtrigger
