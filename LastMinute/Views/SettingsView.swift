//
//  SettingsView.swift
//  LastMinute
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AcademicModule.code) private var modules: [AcademicModule]
    
    // Persistent Preferences using AppStorage
    @AppStorage("user_appearance") private var appearanceSelection: String = "dark" // "system", "dark", "light"
    @AppStorage("default_reminder_timing") private var defaultReminderTiming: String = "1 day before"
    @AppStorage("default_priority") private var defaultPriority: String = "Medium"
    @AppStorage("auto_calendar_sync") private var autoCalendarSync: Bool = true
    @AppStorage("student_name") private var studentName: String = "Alex"
    @AppStorage("student_university") private var studentUniversity: String = "SLIIT Faculty of Computing"
    
    @StateObject private var notifService = NotificationService.shared
    @StateObject private var calService = CalendarService.shared
    
    @State private var showAddModuleSheet: Bool = false
    @State private var showResetDataConfirmation: Bool = false
    @State private var feedbackMessage: String? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                StitchTheme.canvasBase.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        // User Profile Header Card
                        HStack(spacing: 16) {
                            Image("UserAvatar")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 58, height: 58)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(StitchTheme.primaryGold, lineWidth: 2))
                                .gildedGlow(radius: 8, opacity: 0.3)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(studentName)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(StitchTheme.textPrimary)
                                
                                Text(studentUniversity)
                                    .font(.system(size: 13))
                                    .foregroundColor(StitchTheme.textSecondary)
                                
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(StitchTheme.primaryGold)
                                        .frame(width: 6, height: 6)
                                    Text("Academic Year 4 • Semester 1")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(StitchTheme.primaryGold)
                                }
                                .padding(.top, 2)
                            }
                            
                            Spacer()
                        }
                        .padding(16)
                        .stitchCard(cornerRadius: 20, background: StitchTheme.cardElevated)
                        
                        // Section: APPEARANCE
                        VStack(alignment: .leading, spacing: 10) {
                            Text("APPEARANCE")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(0.8)
                                .foregroundColor(StitchTheme.textSecondary)
                            
                            HStack(spacing: 10) {
                                AppearanceOptionButton(
                                    title: "Dark",
                                    icon: "moon.fill",
                                    isSelected: appearanceSelection == "dark"
                                ) {
                                    appearanceSelection = "dark"
                                }
                                
                                AppearanceOptionButton(
                                    title: "Light",
                                    icon: "sun.max.fill",
                                    isSelected: appearanceSelection == "light"
                                ) {
                                    appearanceSelection = "light"
                                }
                                
                                AppearanceOptionButton(
                                    title: "System",
                                    icon: "gearshape",
                                    isSelected: appearanceSelection == "system"
                                ) {
                                    appearanceSelection = "system"
                                }
                            }
                        }
                        
                        // Section: NOTIFICATIONS & REMINDERS
                        VStack(alignment: .leading, spacing: 10) {
                            Text("NOTIFICATIONS & REMINDERS")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(0.8)
                                .foregroundColor(StitchTheme.textSecondary)
                            
                            VStack(spacing: 14) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Notification Access")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(StitchTheme.textPrimary)
                                        Text(notifService.authorizationStatus == .authorized ? "Permission granted" : "Permission not granted")
                                            .font(.system(size: 12))
                                            .foregroundColor(notifService.authorizationStatus == .authorized ? StitchTheme.successMint : StitchTheme.criticalCoral)
                                    }
                                    
                                    Spacer()
                                    
                                    if notifService.authorizationStatus != .authorized {
                                        Button(action: {
                                            Task {
                                                _ = await notifService.requestAuthorization()
                                            }
                                        }) {
                                            Text("Authorize")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(StitchTheme.canvasBase)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(StitchTheme.primaryGold)
                                                .clipShape(Capsule())
                                        }
                                    } else {
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundColor(StitchTheme.successMint)
                                    }
                                }
                                
                                Divider().background(StitchTheme.borderSubtle)
                                
                                HStack {
                                    Text("Default Lead Timing")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(StitchTheme.textPrimary)
                                    
                                    Spacer()
                                    
                                    Picker("", selection: $defaultReminderTiming) {
                                        ForEach(ReminderLeadTime.allCases) { lead in
                                            Text(lead.rawValue).tag(lead.rawValue)
                                        }
                                    }
                                    .tint(StitchTheme.primaryGold)
                                }
                            }
                            .padding(16)
                            .stitchCard(cornerRadius: 18, background: StitchTheme.cardSurface)
                        }
                        
                        // Section: APPLE CALENDAR INTEGRATION
                        VStack(alignment: .leading, spacing: 10) {
                            Text("ECOSYSTEM INTEGRATION")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(0.8)
                                .foregroundColor(StitchTheme.textSecondary)
                            
                            VStack(spacing: 14) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Apple Calendar Access")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(StitchTheme.textPrimary)
                                        Text(calService.isAuthorized ? "Calendar write permission enabled" : "Calendar access disabled")
                                            .font(.system(size: 12))
                                            .foregroundColor(calService.isAuthorized ? StitchTheme.successMint : StitchTheme.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if !calService.isAuthorized {
                                        Button(action: {
                                            Task {
                                                _ = await calService.requestAccess()
                                            }
                                        }) {
                                            Text("Connect")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(StitchTheme.canvasBase)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(StitchTheme.primaryGold)
                                                .clipShape(Capsule())
                                        }
                                    } else {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(StitchTheme.successMint)
                                    }
                                }
                                
                                Divider().background(StitchTheme.borderSubtle)
                                
                                Toggle("Enable Auto-Sync for New Milestones", isOn: $autoCalendarSync)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(StitchTheme.textPrimary)
                                    .tint(StitchTheme.primaryGold)
                            }
                            .padding(16)
                            .stitchCard(cornerRadius: 18, background: StitchTheme.cardSurface)
                        }
                        
                        // Section: ACADEMIC MODULES
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("ACADEMIC MODULES (\(modules.count))")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(0.8)
                                    .foregroundColor(StitchTheme.textSecondary)
                                
                                Spacer()
                                
                                Button(action: { showAddModuleSheet = true }) {
                                    Text("+ Add Module")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(StitchTheme.primaryGold)
                                }
                            }
                            
                            VStack(spacing: 8) {
                                ForEach(modules) { mod in
                                    HStack {
                                        Circle()
                                            .fill(mod.color)
                                            .frame(width: 10, height: 10)
                                        
                                        VStack(alignment: .leading, spacing: 1) {
                                            Text(mod.code)
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(StitchTheme.textPrimary)
                                            Text(mod.name)
                                                .font(.system(size: 12))
                                                .foregroundColor(StitchTheme.textSecondary)
                                                .lineLimit(1)
                                        }
                                        
                                        Spacer()
                                        
                                        let deadlineCount = mod.deadlines?.count ?? 0
                                        Text("\(deadlineCount) targets")
                                            .font(.system(size: 12))
                                            .foregroundColor(StitchTheme.textMuted)
                                    }
                                    .padding(.vertical, 8)
                                    
                                    if mod.id != modules.last?.id {
                                        Divider().background(StitchTheme.borderSubtle.opacity(0.6))
                                    }
                                }
                            }
                            .padding(16)
                            .stitchCard(cornerRadius: 18, background: StitchTheme.cardSurface)
                        }
                        
                        // Section: ABOUT LASTMINUTE
                        VStack(alignment: .leading, spacing: 10) {
                            Text("ABOUT LASTMINUTE")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(0.8)
                                .foregroundColor(StitchTheme.textSecondary)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Application Version")
                                        .font(.system(size: 14))
                                        .foregroundColor(StitchTheme.textPrimary)
                                    Spacer()
                                    Text("v1.0.4 (Obsidian Gilded)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(StitchTheme.primaryGold)
                                }
                                
                                Divider().background(StitchTheme.borderSubtle)
                                
                                HStack {
                                    Text("Design Reference")
                                        .font(.system(size: 14))
                                        .foregroundColor(StitchTheme.textPrimary)
                                    Spacer()
                                    Text("Google Stitch MCP")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(StitchTheme.textSecondary)
                                }
                                
                                Divider().background(StitchTheme.borderSubtle)
                                
                                HStack {
                                    Text("Architecture")
                                        .font(.system(size: 14))
                                        .foregroundColor(StitchTheme.textPrimary)
                                    Spacer()
                                    Text("SwiftUI + SwiftData")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(StitchTheme.textSecondary)
                                }
                            }
                            .padding(16)
                            .stitchCard(cornerRadius: 18, background: StitchTheme.cardSurface)
                        }
                        
                        Spacer(minLength: 80)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showAddModuleSheet) {
                AddModuleSheet()
            }
        }
    }
}

struct AppearanceOptionButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isSelected ? StitchTheme.canvasBase : StitchTheme.textSecondary)
                
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(isSelected ? StitchTheme.canvasBase : StitchTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? StitchTheme.primaryGold : StitchTheme.cardSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? StitchTheme.primaryGold : StitchTheme.borderSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
