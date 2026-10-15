//
//  DateUtilities.swift
//  LastMinute
//

import Foundation

struct DateUtilities {
    static let calendar = Calendar.current
    
    static func daysRemaining(to targetDate: Date) -> Int {
        let now = Date()
        let components = calendar.dateComponents([.day], from: now, to: targetDate)
        return max(0, components.day ?? 0)
    }
    
    static func startOfDay(for date: Date) -> Date {
        calendar.startOfDay(for: date)
    }
    
    static func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        calendar.isDate(date1, inSameDayAs: date2)
    }
    
    static func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    static func dayNumberString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    static func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    static func fullDateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }
    
    static func relativeDueString(for date: Date) -> String {
        if calendar.isDateInToday(date) {
            return "Due Today, \(timeString(from: date))"
        } else if calendar.isDateInTomorrow(date) {
            return "Due Tomorrow, \(timeString(from: date))"
        } else if calendar.isDateInYesterday(date) {
            return "Due Yesterday, \(timeString(from: date))"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM, h:mm a"
            return "Due: \(formatter.string(from: date))"
        }
    }
    
    // Calendar Generation Helper
    static func generateDaysInMonth(for monthDate: Date) -> [CalendarDay] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: monthDate),
              let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let lastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1) else {
            return []
        }
        
        var days: [CalendarDay] = []
        var currentDate = firstWeek.start
        
        while currentDate < lastWeek.end {
            let isCurrentMonth = calendar.isDate(currentDate, equalTo: monthDate, toGranularity: .month)
            let isToday = calendar.isDateInToday(currentDate)
            days.append(CalendarDay(date: currentDate, isCurrentMonth: isCurrentMonth, isToday: isToday))
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return days
    }
}

struct CalendarDay: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let isCurrentMonth: Bool
    let isToday: Bool
}
