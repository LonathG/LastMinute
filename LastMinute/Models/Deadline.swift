//
//  Deadline.swift
//  LastMinute
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Enums

enum Priority: String, CaseIterable, Codable, Identifiable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var id: String { rawValue }
    
    var color: Color {
        switch self {
        case .low:
            return StitchTheme.infoBlue
        case .medium:
            return StitchTheme.secondaryGold
        case .high:
            return StitchTheme.criticalCoral
        }
    }
    
    var containerColor: Color {
        switch self {
        case .low:
            return StitchTheme.infoContainer
        case .medium:
            return Color(hex: "#694B00").opacity(0.6)
        case .high:
            return StitchTheme.criticalContainer
        }
    }
    
    var uppercaseLabel: String {
        switch self {
        case .low: return "LOW"
        case .medium: return "MEDIUM"
        case .high: return "HIGH"
        }
    }
}

enum WorkflowStatus: String, CaseIterable, Codable, Identifiable {
    case notStarted = "Not Started"
    case inProgress = "In Progress"
    case completed = "Completed"
    
    var id: String { rawValue }
    
    var badgeColor: Color {
        switch self {
        case .notStarted:
            return StitchTheme.textSecondary
        case .inProgress:
            return StitchTheme.primaryGold
        case .completed:
            return StitchTheme.successMint
        }
    }
}

enum ReminderLeadTime: String, CaseIterable, Codable, Identifiable {
    case atDeadline = "At deadline"
    case oneHourBefore = "1 hr before"
    case oneDayBefore = "1 day before"
    case twoDaysBefore = "2 days before"
    case custom = "Custom"
    
    var id: String { rawValue }
    
    func targetDate(for deadlineDate: Date, customDate: Date? = nil) -> Date {
        switch self {
        case .atDeadline:
            return deadlineDate
        case .oneHourBefore:
            return deadlineDate.addingTimeInterval(-3600)
        case .oneDayBefore:
            return deadlineDate.addingTimeInterval(-86400)
        case .twoDaysBefore:
            return deadlineDate.addingTimeInterval(-86400 * 2)
        case .custom:
            return customDate ?? deadlineDate.addingTimeInterval(-86400)
        }
    }
}

// MARK: - SwiftData Model

@Model
final class Deadline {
    var id: UUID = UUID()
    var title: String = ""
    var module: AcademicModule?
    var dueDate: Date = Date()
    var priorityRaw: String = Priority.medium.rawValue
    var notes: String = ""
    var workflowStatusRaw: String = WorkflowStatus.notStarted.rawValue
    var isCompleted: Bool = false
    var createdAt: Date = Date()
    var completedAt: Date? = nil
    
    var reminderEnabled: Bool = true
    var reminderDate: Date? = nil
    var reminderLeadTimeRaw: String? = ReminderLeadTime.oneDayBefore.rawValue
    
    var calendarSyncEnabled: Bool = false
    var calendarEventIdentifier: String? = nil
    
    @Relationship(deleteRule: .cascade, inverse: \DeadlineAttachment.deadline)
    var attachments: [DeadlineAttachment]? = []
    
    init(
        id: UUID = UUID(),
        title: String,
        module: AcademicModule? = nil,
        dueDate: Date,
        priority: Priority = .medium,
        notes: String = "",
        workflowStatus: WorkflowStatus = .notStarted,
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        completedAt: Date? = nil,
        reminderEnabled: Bool = true,
        reminderDate: Date? = nil,
        reminderLeadTime: ReminderLeadTime? = .oneDayBefore,
        calendarSyncEnabled: Bool = false,
        calendarEventIdentifier: String? = nil
    ) {
        self.id = id
        self.title = title
        self.module = module
        self.dueDate = dueDate
        self.priorityRaw = priority.rawValue
        self.notes = notes
        self.workflowStatusRaw = workflowStatus.rawValue
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.reminderEnabled = reminderEnabled
        self.reminderDate = reminderDate
        self.reminderLeadTimeRaw = reminderLeadTime?.rawValue
        self.calendarSyncEnabled = calendarSyncEnabled
        self.calendarEventIdentifier = calendarEventIdentifier
    }
    
    // MARK: - Computed Properties
    
    var priority: Priority {
        get { Priority(rawValue: priorityRaw) ?? .medium }
        set { priorityRaw = newValue.rawValue }
    }
    
    var workflowStatus: WorkflowStatus {
        get { WorkflowStatus(rawValue: workflowStatusRaw) ?? .notStarted }
        set { workflowStatusRaw = newValue.rawValue }
    }
    
    var reminderLeadTime: ReminderLeadTime? {
        get {
            guard let raw = reminderLeadTimeRaw else { return nil }
            return ReminderLeadTime(rawValue: raw)
        }
        set { reminderLeadTimeRaw = newValue?.rawValue }
    }
    
    var isOverdue: Bool {
        !isCompleted && dueDate < Date()
    }
    
    var isNextUrgent: Bool {
        !isCompleted && dueDate > Date() && dueDate.timeIntervalSinceNow < 86400 * 3
    }
    
    var remainingTimeInterval: TimeInterval {
        max(0, dueDate.timeIntervalSince(Date()))
    }
    
    var timeComponents: (days: Int, hours: Int, minutes: Int, seconds: Int) {
        let totalSeconds = Int(max(0, dueDate.timeIntervalSince(Date())))
        let days = totalSeconds / 86400
        let hours = (totalSeconds % 86400) / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return (days, hours, minutes, seconds)
    }
    
    var formattedRemainingShort: String {
        if isCompleted {
            return "Completed"
        }
        if isOverdue {
            let diff = Int(abs(dueDate.timeIntervalSinceNow))
            let days = diff / 86400
            let hours = (diff % 86400) / 3600
            if days > 0 {
                return "\(days)d overdue"
            } else {
                return "\(max(1, hours))h overdue"
            }
        }
        
        let c = timeComponents
        if c.days > 0 {
            return "\(c.days)d remaining"
        } else if c.hours > 0 {
            return "\(c.hours)h remaining"
        } else if c.minutes > 0 {
            return "\(c.minutes)m remaining"
        } else {
            return "\(c.seconds)s remaining"
        }
    }
    
    var formattedDueDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM, h:mm a"
        return formatter.string(from: dueDate)
    }
    
    var formattedDueDateTimeDetailed: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM yyyy 'at' h:mm a"
        return formatter.string(from: dueDate)
    }
    
    var windowElapsedFraction: Double {
        let totalDuration = max(1, dueDate.timeIntervalSince(createdAt))
        let elapsed = Date().timeIntervalSince(createdAt)
        return min(1.0, max(0.0, elapsed / totalDuration))
    }
    
    var windowElapsedPercentage: Int {
        Int(windowElapsedFraction * 100)
    }
}
