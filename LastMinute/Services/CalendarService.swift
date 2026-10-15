//
//  CalendarService.swift
//  LastMinute
//

import Foundation
import EventKit
import Combine

@MainActor
final class CalendarService: ObservableObject {
    static let shared = CalendarService()
    
    private let eventStore = EKEventStore()
    @Published var isAuthorized: Bool = false
    
    init() {
        checkAuthorization()
    }
    
    func checkAuthorization() {
        let status = EKEventStore.authorizationStatus(for: .event)
        #if os(iOS)
        if #available(iOS 17.0, *) {
            isAuthorized = (status == .fullAccess)
        } else {
            isAuthorized = (status == .authorized)
        }
        #else
        isAuthorized = (status == .authorized)
        #endif
    }
    
    func requestAccess() async -> Bool {
        do {
            let granted: Bool
            if #available(iOS 17.0, *) {
                granted = try await eventStore.requestFullAccessToEvents()
            } else {
                granted = try await withCheckedThrowingContinuation { continuation in
                    eventStore.requestAccess(to: .event) { success, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: success)
                        }
                    }
                }
            }
            self.isAuthorized = granted
            return granted
        } catch {
            print("Calendar access error: \(error.localizedDescription)")
            self.isAuthorized = false
            return false
        }
    }
    
    func exportOrUpdateEvent(for deadline: Deadline) async -> String? {
        guard deadline.calendarSyncEnabled else { return nil }
        
        if !isAuthorized {
            let granted = await requestAccess()
            guard granted else { return nil }
        }
        
        do {
            let event: EKEvent
            if let existingId = deadline.calendarEventIdentifier,
               let existingEvent = eventStore.event(withIdentifier: existingId) {
                event = existingEvent
            } else {
                event = EKEvent(eventStore: eventStore)
                event.calendar = eventStore.defaultCalendarForNewEvents
            }
            
            let modulePrefix = deadline.module?.code ?? "Academic"
            event.title = "[\(modulePrefix)] \(deadline.title)"
            event.notes = deadline.notes.isEmpty ? "Tracked in LastMinute App" : "\(deadline.notes)\n\nTracked in LastMinute App"
            
            // Due milestone representation (1 hour milestone ending at exact due time)
            event.endDate = deadline.dueDate
            event.startDate = deadline.dueDate.addingTimeInterval(-3600)
            
            // Add alert matching reminder if enabled
            event.alarms = []
            if deadline.reminderEnabled {
                let leadInterval: TimeInterval
                switch deadline.reminderLeadTime {
                case .atDeadline:
                    leadInterval = 0
                case .oneHourBefore:
                    leadInterval = -3600
                case .oneDayBefore:
                    leadInterval = -86400
                case .twoDaysBefore:
                    leadInterval = -86400 * 2
                default:
                    leadInterval = -86400
                }
                event.addAlarm(EKAlarm(relativeOffset: leadInterval))
            }
            
            try eventStore.save(event, span: .thisEvent)
            return event.eventIdentifier
        } catch {
            print("Failed to save Apple Calendar event: \(error.localizedDescription)")
            return nil
        }
    }
    
    func removeEvent(identifier: String?) {
        guard let identifier = identifier, !identifier.isEmpty else { return }
        guard isAuthorized else { return }
        
        if let event = eventStore.event(withIdentifier: identifier) {
            do {
                try eventStore.remove(event, span: .thisEvent)
                print("Calendar event removed: \(identifier)")
            } catch {
                print("Failed to remove calendar event: \(error.localizedDescription)")
            }
        }
    }
}
