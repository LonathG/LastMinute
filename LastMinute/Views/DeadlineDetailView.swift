//
//  DeadlineDetailView.swift
//  LastMinute
//

import SwiftUI
import SwiftData

struct DeadlineDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var deadline: Deadline
    
    @State private var showEditSheet: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    @State private var selectedAttachmentForViewing: DeadlineAttachment? = nil
    
    var body: some View {
        ZStack {
            StitchTheme.canvasBase.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Hero Countdown Card
                    TimelineView(.periodic(from: .now, by: 1)) { _ in
                        let comp = deadline.timeComponents
                        
                        VStack(alignment: .leading, spacing: 14) {
                            // Top Row: Module Chip & Priority Badge
                            HStack {
                                if let mod = deadline.module {
                                    Text(mod.displayChipTitle)
                                        .font(.system(size: 11, weight: .bold))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(StitchTheme.cardSurface)
                                        .foregroundColor(mod.color)
                                        .overlay(Capsule().stroke(StitchTheme.borderSubtle, lineWidth: 1))
                                        .clipShape(Capsule())
                                }
                                
                                Spacer()
                                
                                PriorityBadge(priority: deadline.priority)
                            }
                            
                            // Assignment Title
                            Text(deadline.title)
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(StitchTheme.textPrimary)
                            
                            // Due Date
                            HStack(spacing: 8) {
                                Image(systemName: "calendar")
                                    .foregroundColor(StitchTheme.primaryGold)
                                Text(deadline.formattedDueDateTimeDetailed)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(StitchTheme.textSecondary)
                            }
                            
                            Divider().background(StitchTheme.borderSubtle)
                            
                            // Live Countdown 4-digit display
                            HStack(spacing: 8) {
                                CountdownDigitBox(value: String(format: "%02d", comp.days), unit: "DAYS")
                                CountdownDigitBox(value: String(format: "%02d", comp.hours), unit: "HOURS")
                                CountdownDigitBox(value: String(format: "%02d", comp.minutes), unit: "MINUTES")
                                CountdownDigitBox(value: String(format: "%02d", comp.seconds), unit: "SECONDS")
                            }
                            
                            // Window Elapsed Progress Bar
                            VStack(spacing: 6) {
                                HStack {
                                    HStack(spacing: 4) {
                                        Image(systemName: "clock.arrow.circlepath")
                                            .font(.system(size: 12))
                                            .foregroundColor(StitchTheme.primaryGold)
                                        Text("Window Elapsed")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(StitchTheme.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(deadline.windowElapsedPercentage)%")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(StitchTheme.primaryGold)
                                }
                                
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(StitchTheme.cardHighlight)
                                            .frame(height: 7)
                                        
                                        Capsule()
                                            .fill(StitchTheme.countdownElapsedGradient)
                                            .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(deadline.windowElapsedFraction))), height: 7)
                                    }
                                }
                                .frame(height: 7)
                                
                                HStack {
                                    Text("Assigned \(deadline.createdAt.formatted(.dateTime.month(.abbreviated).day()))")
                                        .font(.system(size: 11))
                                        .foregroundColor(StitchTheme.textMuted)
                                    
                                    Spacer()
                                    
                                    Text("Due \(deadline.dueDate.formatted(.dateTime.month(.abbreviated).day()))")
                                        .font(.system(size: 11))
                                        .foregroundColor(StitchTheme.textMuted)
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(20)
                        .stitchCard(isUrgent: deadline.isNextUrgent, cornerRadius: 24, background: StitchTheme.cardElevated)
                    }
                    
                    // Deliverable Spec Media Banner
                    ZStack(alignment: .bottomLeading) {
                        Image("DeliverableBanner")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 120)
                            .clipped()
                            .overlay(Color.black.opacity(0.45))
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Deliverable Spec")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Academic Artifact & Codebase")
                                    .font(.system(size: 11))
                                    .foregroundColor(StitchTheme.textSecondary)
                            }
                            
                            Spacer()
                            
                            Text("SwiftUI 5.0")
                                .font(.system(size: 11, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.6))
                                .foregroundColor(StitchTheme.primaryGold)
                                .clipShape(Capsule())
                        }
                        .padding(14)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(StitchTheme.borderSubtle, lineWidth: 1)
                    )
                    
                    // Section: ACADEMIC INSTRUCTIONS
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ACADEMIC INSTRUCTIONS")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(0.8)
                            .foregroundColor(StitchTheme.textSecondary)
                        
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "doc.text.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(StitchTheme.primaryGold)
                                    .padding(8)
                                    .background(StitchTheme.canvasSecondary)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Submission Scope")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(StitchTheme.textPrimary)
                                    
                                    Text(deadline.notes.isEmpty ? "Submit final project archive containing source code, design specification PDF, and verification checklist before 11:59 PM." : deadline.notes)
                                        .font(.system(size: 13))
                                        .foregroundColor(StitchTheme.textSecondary)
                                        .lineSpacing(3)
                                }
                            }
                            
                            // Attachments List
                            if let atts = deadline.attachments, !atts.isEmpty {
                                Divider().background(StitchTheme.borderSubtle)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("ATTACHED RESOURCES")
                                        .font(.system(size: 10, weight: .bold))
                                        .tracking(0.6)
                                        .foregroundColor(StitchTheme.textMuted)
                                    
                                    ForEach(atts) { att in
                                        Button(action: {
                                            selectedAttachmentForViewing = att
                                        }) {
                                            HStack(spacing: 10) {
                                                Image(systemName: att.isWebURL ? "link.circle.fill" : "doc.badge.arrow.up.fill")
                                                    .foregroundColor(StitchTheme.primaryGold)
                                                
                                                VStack(alignment: .leading, spacing: 1) {
                                                    Text(att.fileName)
                                                        .font(.system(size: 13, weight: .semibold))
                                                        .foregroundColor(StitchTheme.textPrimary)
                                                        .lineLimit(1)
                                                    
                                                    if att.isWebURL, let u = att.remoteURL {
                                                        Text(u)
                                                            .font(.system(size: 11))
                                                            .foregroundColor(StitchTheme.textSecondary)
                                                            .lineLimit(1)
                                                    } else {
                                                        Text("Local document • \(att.formattedFileSize)")
                                                            .font(.system(size: 11))
                                                            .foregroundColor(StitchTheme.textSecondary)
                                                    }
                                                }
                                                
                                                Spacer()
                                                
                                                Image(systemName: "arrow.up.right.square")
                                                    .foregroundColor(StitchTheme.primaryGold)
                                            }
                                            .padding(10)
                                            .background(StitchTheme.canvasSecondary)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .stitchCard(cornerRadius: 18, background: StitchTheme.cardSurface)
                    }
                    
                    // Section: SYSTEM & SYNC TELEMETRY
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SYSTEM & SYNC TELEMETRY")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(0.8)
                            .foregroundColor(StitchTheme.textSecondary)
                        
                        VStack(spacing: 12) {
                            // Smart Alert Row
                            HStack {
                                HStack(spacing: 10) {
                                    Image(systemName: "bell.badge.fill")
                                        .foregroundColor(StitchTheme.primaryGold)
                                        .frame(width: 28, height: 28)
                                        .background(StitchTheme.canvasSecondary)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Smart Alert")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(StitchTheme.textPrimary)
                                        Text(deadline.reminderEnabled ? (deadline.reminderLeadTime?.rawValue ?? "Active") : "Disabled")
                                            .font(.system(size: 12))
                                            .foregroundColor(StitchTheme.textSecondary)
                                    }
                                }
                                
                                Spacer()
                                
                                if deadline.reminderEnabled {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(StitchTheme.successMint)
                                }
                            }
                            
                            Divider().background(StitchTheme.borderSubtle)
                            
                            // Calendar Integration Row
                            HStack {
                                HStack(spacing: 10) {
                                    Image(systemName: "calendar.badge.clock")
                                        .foregroundColor(StitchTheme.successMint)
                                        .frame(width: 28, height: 28)
                                        .background(StitchTheme.canvasSecondary)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Calendar Integration")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(StitchTheme.textPrimary)
                                        Text(deadline.calendarSyncEnabled ? "Synced to Apple Calendar" : "Not synchronized")
                                            .font(.system(size: 12))
                                            .foregroundColor(StitchTheme.textSecondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Text(deadline.calendarSyncEnabled ? "Synced" : "Off")
                                    .font(.system(size: 11, weight: .bold))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(deadline.calendarSyncEnabled ? StitchTheme.successContainer : StitchTheme.canvasSecondary)
                                    .foregroundColor(deadline.calendarSyncEnabled ? StitchTheme.successMint : StitchTheme.textSecondary)
                                    .clipShape(Capsule())
                            }
                            
                            Divider().background(StitchTheme.borderSubtle)
                            
                            // Workflow State Selector
                            HStack {
                                HStack(spacing: 10) {
                                    Image(systemName: "hourglass")
                                        .foregroundColor(StitchTheme.secondaryGold)
                                        .frame(width: 28, height: 28)
                                        .background(StitchTheme.canvasSecondary)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Workflow State")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(StitchTheme.textPrimary)
                                        Text("Milestone tracking status")
                                            .font(.system(size: 12))
                                            .foregroundColor(StitchTheme.textSecondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Menu {
                                    ForEach(WorkflowStatus.allCases) { st in
                                        Button(st.rawValue) {
                                            deadline.workflowStatus = st
                                            if st == .completed {
                                                deadline.isCompleted = true
                                                deadline.completedAt = Date()
                                                NotificationService.shared.cancelNotification(for: deadline.id)
                                            }
                                            try? modelContext.save()
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Circle()
                                            .fill(deadline.workflowStatus.badgeColor)
                                            .frame(width: 6, height: 6)
                                        Text(deadline.workflowStatus.rawValue)
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(deadline.workflowStatus.badgeColor)
                                        Image(systemName: "chevron.up.chevron.down")
                                            .font(.system(size: 9))
                                            .foregroundColor(StitchTheme.textSecondary)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(StitchTheme.canvasSecondary)
                                    .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(16)
                        .stitchCard(cornerRadius: 18, background: StitchTheme.cardSurface)
                    }
                    
                    // Advisory Focus Tip Banner
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(StitchTheme.primaryGold)
                            .font(.system(size: 16))
                        
                        Text("Focus session recommended: schedule 2 hours today to complete design specs and avoid last-hour upload bottlenecks.")
                            .font(.system(size: 12))
                            .foregroundColor(StitchTheme.textSecondary)
                            .lineSpacing(2)
                    }
                    .padding(14)
                    .background(StitchTheme.canvasSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(StitchTheme.borderSubtle, lineWidth: 1)
                    )
                    
                    // Actions Stack
                    VStack(spacing: 12) {
                        GoldButton(
                            title: deadline.isCompleted ? "Mark as Incomplete" : "Mark as Completed",
                            icon: deadline.isCompleted ? "arrow.uturn.backward" : "checkmark"
                        ) {
                            toggleCompletion()
                        }
                        
                        SecondaryCardButton(title: "Edit Deadline", icon: "pencil") {
                            showEditSheet = true
                        }
                        
                        SecondaryCardButton(title: "Delete Deadline", icon: "trash", isDestructive: true) {
                            showDeleteConfirmation = true
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
                .padding(20)
            }
        }
        .navigationTitle("Deadline Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Edit") {
                    showEditSheet = true
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(StitchTheme.primaryGold)
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditDeadlineView(deadline: deadline)
        }
        .sheet(item: $selectedAttachmentForViewing) { att in
            AttachmentViewerSheet(attachment: att)
        }
        .confirmationDialog(
            "Delete Deadline?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Deadline", role: .destructive) {
                deleteDeadline()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently remove this assignment, its attachments, and scheduled notifications.")
        }
    }
    
    private func toggleCompletion() {
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
    
    private func deleteDeadline() {
        // Cancel notifications
        NotificationService.shared.cancelNotification(for: deadline.id)
        
        // Remove calendar event
        if let eventId = deadline.calendarEventIdentifier {
            CalendarService.shared.removeEvent(identifier: eventId)
        }
        
        // Clean up attachments
        if let atts = deadline.attachments {
            for att in atts {
                AttachmentService.shared.deleteFile(at: att.localRelativePath)
            }
        }
        
        modelContext.delete(deadline)
        try? modelContext.save()
        
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(.success)
        dismiss()
    }
}
