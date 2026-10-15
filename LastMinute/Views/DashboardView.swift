//
//  DashboardView.swift
//  LastMinute
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Deadline.dueDate) private var deadlines: [Deadline]
    
    @Binding var selectedTab: Int
    @Binding var hideTabBar: Bool
    @State private var showCreateDeadline: Bool = false
    @State private var selectedDeadlineForDetails: Deadline? = nil
    @State private var showNotificationAlert: Bool = false
    
    // Greeting helper
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            return "Good morning, Alex"
        } else if hour < 17 {
            return "Good afternoon, Alex"
        } else {
            return "Good evening, Alex"
        }
    }
    
    // Derived deadlines
    private var activeDeadlines: [Deadline] {
        deadlines.filter { !$0.isCompleted }
    }
    
    private var nextUrgentDeadline: Deadline? {
        activeDeadlines.first
    }
    
    private var upcomingDeadlines: [Deadline] {
        guard let next = nextUrgentDeadline else { return [] }
        return activeDeadlines.filter { $0.id != next.id }
    }
    
    private var completedCount: Int {
        deadlines.filter { $0.isCompleted }.count
    }
    
    private var overdueCount: Int {
        deadlines.filter { $0.isOverdue }.count
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                StitchTheme.canvasBase.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Top Header: Branding, Greeting, Sync Pill, Icons
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(alignment: .center) {
                                HStack(spacing: 10) {
                                    Image("AppLogo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 32, height: 32)
                                    
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text("LASTMINUTE")
                                            .font(.system(size: 10, weight: .bold))
                                            .tracking(1.0)
                                            .foregroundColor(StitchTheme.primaryGold)
                                        
                                        Text("Dashboard")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(StitchTheme.textPrimary)
                                    }
                                }
                                
                                Spacer()
                                
                                // Notification Bell
                                Button(action: {
                                    showNotificationAlert = true
                                }) {
                                    ZStack(alignment: .topTrailing) {
                                        Image(systemName: "bell")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(StitchTheme.textPrimary)
                                            .frame(width: 38, height: 38)
                                            .background(StitchTheme.cardElevated)
                                            .clipShape(Circle())
                                        
                                        Circle()
                                            .fill(StitchTheme.primaryGold)
                                            .frame(width: 7, height: 7)
                                            .offset(x: -6, y: 6)
                                    }
                                }
                                .buttonStyle(.plain)
                                
                                // Profile Avatar (Shortcut to Settings tab)
                                Button(action: {
                                    selectedTab = 3
                                }) {
                                    Image("UserAvatar")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 36, height: 36)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(StitchTheme.primaryGold.opacity(0.4), lineWidth: 1.5))
                                }
                                .buttonStyle(.plain)
                            }
                            
                            // Greeting & Sync Badge
                            HStack {
                                Text(greetingText)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(StitchTheme.textSecondary)
                                
                                Spacer()
                                
                                HStack(spacing: 5) {
                                    Circle()
                                        .fill(StitchTheme.primaryGold)
                                        .frame(width: 6, height: 6)
                                    Text("SYNC ACTIVE")
                                        .font(.system(size: 10, weight: .bold))
                                        .tracking(0.6)
                                        .foregroundColor(StitchTheme.primaryGold)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(StitchTheme.cardElevated)
                                .clipShape(Capsule())
                            }
                            
                            Text("Your Deadlines")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(StitchTheme.textPrimary)
                        }
                        .padding(.top, 4)
                        
                        // Main Featured Countdown Card
                        if let featured = nextUrgentDeadline {
                            CountdownCard(deadline: featured) {
                                selectedDeadlineForDetails = featured
                            }
                        } else {
                            // Empty state if no pending deadlines
                            VStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(StitchTheme.successMint)
                                
                                Text("All Caught Up!")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(StitchTheme.textPrimary)
                                
                                Text("You have no pending deadlines. Tap the gold button below to create a new assignment milestone.")
                                    .font(.system(size: 13))
                                    .foregroundColor(StitchTheme.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 36)
                            .stitchCard(cornerRadius: 22, background: StitchTheme.cardSurface)
                        }
                        
                        // Summary Metrics Row: Upcoming, Completed, Overdue
                        HStack(spacing: 12) {
                            SummaryCard(
                                icon: "calendar",
                                dotColor: StitchTheme.primaryGold,
                                count: activeDeadlines.count,
                                label: "UPCOMING"
                            )
                            
                            SummaryCard(
                                icon: "checkmark.circle",
                                dotColor: StitchTheme.successMint,
                                count: completedCount,
                                label: "COMPLETED",
                                countColor: StitchTheme.successMint
                            )
                            
                            SummaryCard(
                                icon: "exclamationmark.triangle",
                                dotColor: StitchTheme.criticalCoral,
                                count: overdueCount,
                                label: "OVERDUE",
                                countColor: overdueCount > 0 ? StitchTheme.criticalCoral : StitchTheme.textSecondary
                            )
                        }
                        
                        // Upcoming Deadlines Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Upcoming Deadlines")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(StitchTheme.textPrimary)
                                
                                Spacer()
                                
                                Button(action: {
                                    selectedTab = 1 // Switch to Calendar tab
                                }) {
                                    Text("SEE ALL (\(deadlines.count))")
                                        .font(.system(size: 11, weight: .bold))
                                        .tracking(0.6)
                                        .foregroundColor(StitchTheme.primaryGold)
                                }
                            }
                            
                            if upcomingDeadlines.isEmpty {
                                Text("No further upcoming assignments scheduled.")
                                    .font(.system(size: 13))
                                    .foregroundColor(StitchTheme.textMuted)
                                    .padding(.vertical, 8)
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(upcomingDeadlines) { deadline in
                                        DeadlineCard(
                                            deadline: deadline,
                                            onToggleComplete: {
                                                toggleCompletion(for: deadline)
                                            },
                                            onTap: {
                                                selectedDeadlineForDetails = deadline
                                            }
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.top, 4)
                        
                        // Extra bottom padding for floating button & tab bar
                        Spacer(minLength: 90)
                    }
                    .padding(.horizontal, 16)
                }
                
                // Floating Gold Add Deadline Button
                FloatingAddButton {
                    showCreateDeadline = true
                }
                .padding(.trailing, 20)
                .padding(.bottom, 24)
            }
            .sheet(isPresented: $showCreateDeadline) {
                CreateDeadlineView()
            }
            .navigationDestination(item: $selectedDeadlineForDetails) { item in
                DeadlineDetailView(deadline: item)
            }
            .alert("Notifications & Reminders", isPresented: $showNotificationAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("LastMinute smart alerts are scheduled automatically before each assignment deadline.")
            }
            .onAppear {
                if CommandLine.arguments.contains("-create") {
                    showCreateDeadline = true
                } else if CommandLine.arguments.contains("-detail") {
                    selectedDeadlineForDetails = nextUrgentDeadline
                }
                hideTabBar = (selectedDeadlineForDetails != nil)
            }
            .onChange(of: selectedDeadlineForDetails) { _, newValue in
                hideTabBar = (newValue != nil)
            }
        }
    }
    
    private func toggleCompletion(for deadline: Deadline) {
        deadline.isCompleted.toggle()
        if deadline.isCompleted {
            deadline.completedAt = Date()
            deadline.workflowStatus = .completed
            NotificationService.shared.cancelNotification(for: deadline.id)
        } else {
            deadline.completedAt = nil
            deadline.workflowStatus = .inProgress
            NotificationService.shared.scheduleNotification(for: deadline)
        }
        try? modelContext.save()
    }
}
