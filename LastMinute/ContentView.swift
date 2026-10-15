//
//  ContentView.swift
//  LastMinute
//
//  Created by Rusheni Botheju on 2026-10-15.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var existingDeadlines: [Deadline]
    @Query private var existingModules: [AcademicModule]
    
    @AppStorage("user_appearance") private var appearanceSelection: String = "dark"
    @State private var hideTabBar: Bool = false
    @State private var selectedTab: Int = {
        if CommandLine.arguments.contains("-tab1") { return 1 }
        if CommandLine.arguments.contains("-tab2") { return 2 }
        if CommandLine.arguments.contains("-tab3") { return 3 }
        return 0
    }()
    
    var preferredScheme: ColorScheme? {
        switch appearanceSelection {
        case "dark": return .dark
        case "light": return .light
        default: return nil
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Tab Content
            Group {
                switch selectedTab {
                case 0:
                    DashboardView(selectedTab: $selectedTab, hideTabBar: $hideTabBar)
                case 1:
                    CalendarView(hideTabBar: $hideTabBar)
                case 2:
                    StatisticsView()
                case 3:
                    SettingsView()
                default:
                    DashboardView(selectedTab: $selectedTab, hideTabBar: $hideTabBar)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Stitch Frosted Bottom Navigation Bar
            if !hideTabBar {
                VStack(spacing: 0) {
                    Divider()
                        .background(StitchTheme.borderSubtle.opacity(0.8))
                    
                    HStack {
                        StitchTabItem(
                            icon: "clock.fill",
                            label: "Home",
                            isSelected: selectedTab == 0
                        ) {
                            selectedTab = 0
                        }
                        
                        StitchTabItem(
                            icon: "calendar",
                            label: "Calendar",
                            isSelected: selectedTab == 1
                        ) {
                            selectedTab = 1
                        }
                        
                        StitchTabItem(
                            icon: "chart.bar.fill",
                            label: "Statistics",
                            isSelected: selectedTab == 2
                        ) {
                            selectedTab = 2
                        }
                        
                        StitchTabItem(
                            icon: "gearshape.fill",
                            label: "Settings",
                            isSelected: selectedTab == 3
                        ) {
                            selectedTab = 3
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                    .padding(.bottom, 18)
                    .background(
                        StitchTheme.canvasBase.opacity(0.92)
                            .background(.ultraThinMaterial)
                    )
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: hideTabBar)
        .preferredColorScheme(preferredScheme)
        .onAppear {
            seedInitialAcademicDataIfNeeded()
            if CommandLine.arguments.contains("-tab1") { selectedTab = 1 }
            else if CommandLine.arguments.contains("-tab2") { selectedTab = 2 }
            else if CommandLine.arguments.contains("-tab3") { selectedTab = 3 }
        }
    }
    
    // MARK: - Initial Seeding
    private func seedInitialAcademicDataIfNeeded() {
        guard existingModules.isEmpty && existingDeadlines.isEmpty else { return }
        
        // 1. Create Academic Modules
        let madd = AcademicModule(
            code: "SE4041",
            name: "Mobile Application Development",
            shortLabel: "MADD",
            colorHex: "#F2CC7B" // Gold
        )
        let cloud = AcademicModule(
            code: "CS3022",
            name: "Cloud Computing & Distributed Systems",
            shortLabel: "Cloud",
            colorHex: "#ECC06F" // Amber
        )
        let hci = AcademicModule(
            code: "IT3010",
            name: "Human Computer Interaction",
            shortLabel: "HCI",
            colorHex: "#89A9D8" // Blue
        )
        let dbms = AcademicModule(
            code: "CS2040",
            name: "Database Management Systems",
            shortLabel: "DBMS",
            colorHex: "#7BC9A4" // Mint
        )
        let research = AcademicModule(
            code: "RS4010",
            name: "Research Methodology & Project",
            shortLabel: "RESEARCH",
            colorHex: "#C59BEE" // Purple
        )
        
        modelContext.insert(madd)
        modelContext.insert(cloud)
        modelContext.insert(hci)
        modelContext.insert(dbms)
        modelContext.insert(research)
        
        let now = Date()
        
        // 2. Next Urgent Featured Deadline (Matches Stitch screen: 2 days 14 hours away)
        let twoDaysAndHours: TimeInterval = (2.0 * 86400.0) + (14.0 * 3600.0) + (35.0 * 60.0)
        let urgentDueDate = now.addingTimeInterval(twoDaysAndHours)
        let urgent = Deadline(
            title: "Mobile App Assignment",
            module: madd,
            dueDate: urgentDueDate,
            priority: .high,
            notes: "Submit final zip archive containing SwiftUI source code, design specification PDF, and demo video link to Canvas portal before 11:59 PM.",
            workflowStatus: .inProgress,
            isCompleted: false,
            createdAt: now.addingTimeInterval(-86400 * 10),
            reminderEnabled: true,
            reminderLeadTime: .oneDayBefore,
            calendarSyncEnabled: true
        )
        
        // Add sample spec attachment
        let sampleAtt = DeadlineAttachment(
            fileName: "SE4041_Assignment_Brief_v2.pdf",
            fileType: "pdf",
            localRelativePath: nil,
            remoteURL: "https://canvas.sliit.lk",
            fileSizeBytes: 2450000
        )
        sampleAtt.deadline = urgent
        urgent.attachments = [sampleAtt]
        modelContext.insert(urgent)
        
        // 3. Upcoming Deadlines
        let d1 = Deadline(
            title: "UI/UX Design Report",
            module: hci,
            dueDate: now.addingTimeInterval(3600 * 14), // tomorrow morning
            priority: .medium,
            notes: "Heuristic evaluation and Figma hi-fi interactive prototype documentation.",
            workflowStatus: .inProgress,
            isCompleted: false,
            createdAt: now.addingTimeInterval(-86400 * 5)
        )
        modelContext.insert(d1)
        
        let d2 = Deadline(
            title: "Database Assignment",
            module: dbms,
            dueDate: now.addingTimeInterval(86400 * 5),
            priority: .low,
            notes: "Relational database schema normalization and SQL query optimization report.",
            workflowStatus: .notStarted,
            isCompleted: false,
            createdAt: now.addingTimeInterval(-86400 * 3)
        )
        modelContext.insert(d2)
        
        let d3 = Deadline(
            title: "Research Presentation",
            module: research,
            dueDate: now.addingTimeInterval(86400 * 7),
            priority: .high,
            notes: "15-minute viva presentation deck with empirical validation results.",
            workflowStatus: .notStarted,
            isCompleted: false,
            createdAt: now.addingTimeInterval(-86400 * 4)
        )
        modelContext.insert(d3)
        
        let d4 = Deadline(
            title: "Distributed Systems Quiz",
            module: cloud,
            dueDate: now.addingTimeInterval((2.0 * 86400.0) + (18.0 * 3600.0)),
            priority: .medium,
            notes: "Raft consensus, CAP theorem, and MapReduce architecture review.",
            workflowStatus: .notStarted,
            isCompleted: false,
            createdAt: now.addingTimeInterval(-86400 * 2)
        )
        modelContext.insert(d4)
        
        // 4. Seed Completed Deadlines to fulfill 75% completion rate (12 completed out of 16 total)
        let pastCompletedTitles = [
            ("MADD Practical 01: SwiftUI Foundations", madd),
            ("MADD Practical 02: State & Bindings", madd),
            ("Cloud Lab 01: AWS EC2 Provisioning", cloud),
            ("Cloud Lab 02: Kubernetes Pods", cloud),
            ("HCI Milestone 01: User Personas", hci),
            ("HCI Milestone 02: Wireframing", hci),
            ("DBMS Lab 01: E-R Modeling", dbms),
            ("DBMS Lab 02: Complex Queries", dbms),
            ("Research Proposal Document", research),
            ("Literature Review Chapter", research),
            ("Cloud Computing Midterm", cloud),
            ("Mobile Architecture Presentation", madd)
        ]
        
        for (idx, item) in pastCompletedTitles.enumerated() {
            let pastDueDate = now.addingTimeInterval(-Double((idx + 1) * 86400 * 3))
            let comp = Deadline(
                title: item.0,
                module: item.1,
                dueDate: pastDueDate,
                priority: idx % 2 == 0 ? .medium : .high,
                notes: "Successfully evaluated and graded.",
                workflowStatus: .completed,
                isCompleted: true,
                createdAt: pastDueDate.addingTimeInterval(-86400 * 14),
                completedAt: pastDueDate.addingTimeInterval(-3600 * 4) // On time
            )
            modelContext.insert(comp)
        }
        
        try? modelContext.save()
    }
}

// Stitch Navigation Bar Item Component
struct StitchTabItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
            action()
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 19, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? StitchTheme.primaryGold : StitchTheme.textSecondary)
                
                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? StitchTheme.primaryGold : StitchTheme.textSecondary)
                
                // Micro gold indicator dot when selected
                Circle()
                    .fill(isSelected ? StitchTheme.primaryGold : Color.clear)
                    .frame(width: 4, height: 4)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Deadline.self, AcademicModule.self, DeadlineAttachment.self], inMemory: true)
}
