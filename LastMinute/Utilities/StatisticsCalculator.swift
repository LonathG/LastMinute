//
//  StatisticsCalculator.swift
//  LastMinute
//

import Foundation

struct DayActivity: Identifiable {
    let id = UUID()
    let dayName: String // "Mon", "Tue", ...
    let dayShort: String // "M", "T"
    let count: Int
    let isCurrentDay: Bool
    let date: Date
}

struct PriorityStat {
    let priority: Priority
    let count: Int
    let fraction: Double
}

struct SemesterStats {
    let totalCount: Int
    let completedCount: Int
    let pendingCount: Int
    let overdueCount: Int
    let completionRate: Int // 0 - 100
    let onTimeRate: Int     // 0 - 100
    
    let highPriorityCount: Int
    let mediumPriorityCount: Int
    let lowPriorityCount: Int
    
    let weeklyActivity: [DayActivity]
    let achievementUnlocked: Bool
    let achievementText: String
    let achievementBadge: String
}

struct StatisticsCalculator {
    static let calendar = Calendar.current
    
    static func calculate(deadlines: [Deadline]) -> SemesterStats {
        let total = deadlines.count
        let completed = deadlines.filter { $0.isCompleted }.count
        let overdue = deadlines.filter { $0.isOverdue }.count
        let pending = max(0, total - completed - overdue)
        
        let completionRate = total > 0 ? Int((Double(completed) / Double(total)) * 100) : 0
        
        let onTimeCompleted = deadlines.filter { d in
            guard d.isCompleted, let completedAt = d.completedAt else { return false }
            return completedAt <= d.dueDate
        }.count
        
        let onTimeRate: Int
        if completed > 0 {
            onTimeRate = Int((Double(onTimeCompleted) / Double(completed)) * 100)
        } else if total > 0 {
            onTimeRate = max(0, 100 - Int((Double(overdue) / Double(total)) * 100))
        } else {
            onTimeRate = 100
        }
        
        let highCount = deadlines.filter { $0.priority == .high }.count
        let medCount = deadlines.filter { $0.priority == .medium }.count
        let lowCount = deadlines.filter { $0.priority == .low }.count
        
        // Weekly activity: calculate for the current week (7 days)
        var calendarMonday = Calendar.current
        calendarMonday.firstWeekday = 2 // Monday start
        let today = Date()
        guard let weekInterval = calendarMonday.dateInterval(of: .weekOfYear, for: today) else {
            return SemesterStats(
                totalCount: total,
                completedCount: completed,
                pendingCount: pending,
                overdueCount: overdue,
                completionRate: completionRate,
                onTimeRate: onTimeRate,
                highPriorityCount: highCount,
                mediumPriorityCount: medCount,
                lowPriorityCount: lowCount,
                weeklyActivity: [],
                achievementUnlocked: total > 0,
                achievementText: "Keep up the momentum to reach your academic targets.",
                achievementBadge: "Top 5%"
            )
        }
        
        var activities: [DayActivity] = []
        let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        
        for i in 0..<7 {
            if let dayDate = calendarMonday.date(byAdding: .day, value: i, to: weekInterval.start) {
                let isCurrentDay = calendarMonday.isDate(dayDate, inSameDayAs: today)
                let completedOnDay = deadlines.filter { d in
                    if let cAt = d.completedAt {
                        return calendarMonday.isDate(cAt, inSameDayAs: dayDate)
                    } else if d.isCompleted {
                        // fallback to dueDate if completedAt is nil
                        return calendarMonday.isDate(d.dueDate, inSameDayAs: dayDate)
                    }
                    return false
                }.count
                
                activities.append(DayActivity(
                    dayName: dayNames[i],
                    dayShort: String(dayNames[i].prefix(1)),
                    count: completedOnDay,
                    isCurrentDay: isCurrentDay,
                    date: dayDate
                ))
            }
        }
        
        // Dynamic achievement message based on real progress
        let achievementText: String
        let achievementBadge: String
        if onTimeRate >= 90 && completed > 0 {
            achievementBadge = "Top 5%"
            achievementText = "Great progress! You've maintained a \(onTimeRate)% on-time completion rate over the semester."
        } else if completionRate >= 75 {
            achievementBadge = "Honor Roll"
            achievementText = "Impressive pace! Over \(completionRate)% of your academic targets have been finalized."
        } else if overdue == 0 && total > 0 {
            achievementBadge = "Zero Overdue"
            achievementText = "Outstanding focus! Zero overdue submissions recorded across all modules."
        } else {
            achievementBadge = "Active Scholar"
            achievementText = "\(pending) assignments currently in queue. Stay ahead of your deadlines."
        }
        
        return SemesterStats(
            totalCount: total,
            completedCount: completed,
            pendingCount: pending,
            overdueCount: overdue,
            completionRate: completionRate,
            onTimeRate: onTimeRate,
            highPriorityCount: highCount,
            mediumPriorityCount: medCount,
            lowPriorityCount: lowCount,
            weeklyActivity: activities,
            achievementUnlocked: total > 0,
            achievementText: achievementText,
            achievementBadge: achievementBadge
        )
    }
}
