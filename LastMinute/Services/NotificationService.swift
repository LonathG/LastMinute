//
//  NotificationService.swift
//  LastMinute
//

import Foundation
import UserNotifications
import Combine

@MainActor
final class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private let center = UNUserNotificationCenter.current()
    
    init() {
        Task {
            await checkStatus()
        }
    }
    
    func checkStatus() async {
        let settings = await center.notificationSettings()
        self.authorizationStatus = settings.authorizationStatus
    }
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await checkStatus()
            return granted
        } catch {
            print("Notification authorization error: \(error.localizedDescription)")
            return false
        }
    }
    
    func scheduleNotification(for deadline: Deadline) {
        guard deadline.reminderEnabled else {
            cancelNotification(for: deadline.id)
            return
        }
        
        let targetDate: Date
        if let custom = deadline.reminderDate {
            targetDate = custom
        } else if let lead = deadline.reminderLeadTime {
            targetDate = lead.targetDate(for: deadline.dueDate)
        } else {
            targetDate = deadline.dueDate.addingTimeInterval(-86400)
        }
        
        // Never schedule reminders in the past
        guard targetDate > Date() else {
            print("Target reminder date is in the past; skipping scheduling.")
            return
        }
        
        // Cancel existing first
        cancelNotification(for: deadline.id)
        
        let content = UNMutableNotificationContent()
        let moduleCode = deadline.module?.code ?? "Academic"
        content.title = "\(moduleCode): \(deadline.title)"
        
        let timeRemaining = DateUtilities.relativeDueString(for: deadline.dueDate)
        content.body = "Impending deadline. \(timeRemaining). Review instructions and finalize submission."
        content.sound = .default
        content.categoryIdentifier = "DEADLINE_REMINDER"
        
        let triggerDateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: targetDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
        
        let identifier = deadline.id.uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully for \(targetDate)")
            }
        }
    }
    
    func cancelNotification(for deadlineId: UUID) {
        let identifier = deadlineId.uuidString
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        center.removeDeliveredNotifications(withIdentifiers: [identifier])
    }
}
