//
//  LastMinuteTests.swift
//  LastMinuteTests
//

import XCTest
import SwiftUI
@testable import LastMinute

final class LastMinuteTests: XCTestCase {

    func testDeadlineTimeCalculations() {
        let now = Date()
        let twoDaysLater = now.addingTimeInterval(86400 * 2 + 3600 * 5)
        
        let deadline = Deadline(
            title: "Unit Test Assignment",
            dueDate: twoDaysLater,
            priority: .high,
            isCompleted: false
        )
        
        XCTAssertFalse(deadline.isCompleted)
        XCTAssertFalse(deadline.isOverdue)
        XCTAssertGreaterThan(deadline.remainingTimeInterval, 0)
        
        let comp = deadline.timeComponents
        XCTAssertEqual(comp.days, 2)
        XCTAssertEqual(comp.hours, 5)
    }
    
    func testStatisticsCalculations() {
        let now = Date()
        let mod = AcademicModule(code: "SE4041", name: "Mobile App Development", shortLabel: "MADD")
        
        let d1 = Deadline(
            title: "Task 1",
            module: mod,
            dueDate: now.addingTimeInterval(86400),
            priority: .high,
            isCompleted: false
        )
        
        let d2 = Deadline(
            title: "Task 2",
            module: mod,
            dueDate: now.addingTimeInterval(-86400),
            priority: .medium,
            isCompleted: true,
            completedAt: now.addingTimeInterval(-86400 * 2)
        )
        
        let stats = StatisticsCalculator.calculate(deadlines: [d1, d2])
        XCTAssertEqual(stats.totalCount, 2)
        XCTAssertEqual(stats.completedCount, 1)
        XCTAssertEqual(stats.pendingCount, 1)
        XCTAssertEqual(stats.overdueCount, 0)
        XCTAssertEqual(stats.completionRate, 50)
        XCTAssertEqual(stats.onTimeRate, 100)
    }
    
    func testDateUtilities() {
        let now = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now)!
        XCTAssertEqual(DateUtilities.daysRemaining(to: tomorrow), 1)
        
        let daysInMonth = DateUtilities.generateDaysInMonth(for: now)
        XCTAssertGreaterThanOrEqual(daysInMonth.count, 28)
    }
    
    func testModuleChipTitle() {
        let mod = AcademicModule(code: "IT3010", name: "Human Computer Interaction", shortLabel: "HCI")
        XCTAssertEqual(mod.displayChipTitle, "IT3010 — HCI")
    }
}
