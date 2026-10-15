//
//  CreateDeadlineView.swift
//  LastMinute
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct CreateDeadlineView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AcademicModule.code) private var modules: [AcademicModule]
    
    // Form States
    @State private var title: String = ""
    @State private var selectedModule: AcademicModule? = nil
    @State private var dueDate: Date = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
    @State private var priority: Priority = .medium
    @State private var workflowStatus: WorkflowStatus = .notStarted
    @State private var notes: String = ""
    
    // Reminders
    @State private var reminderEnabled: Bool = true
    @State private var selectedLeadTime: ReminderLeadTime = .oneDayBefore
    @State private var customReminderDate: Date = Date().addingTimeInterval(86400)
    
    // Calendar Integration
    @State private var calendarSyncEnabled: Bool = false
    
    // Attachments & URLs
    @State private var pendingAttachments: [(name: String, type: String, path: String?, url: String?, size: Int64)] = []
    @State private var showFileImporter: Bool = false
    @State private var showURLAlert: Bool = false
    @State private var urlInput: String = ""
    @State private var urlTitleInput: String = ""
    
    // Add Module Sheet
    @State private var showAddModuleSheet: Bool = false
    
    // Validation & Success Feedback
    @State private var validationError: String? = nil
    @State private var showSuccessBadge: Bool = false
    
    // Optional preselected date (e.g. from Calendar)
    var initialDate: Date? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                StitchTheme.canvasBase.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Section: GENERAL INFORMATION
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("GENERAL INFORMATION")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(0.8)
                                    .foregroundColor(StitchTheme.textSecondary)
                                
                                Spacer()
                                
                                Text("Step 1 of 4")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(StitchTheme.primaryGold)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Assignment / Milestone Title")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(StitchTheme.textPrimary)
                                
                                TextField("e.g. Distributed Systems Final Project", text: $title)
                                    .foregroundColor(StitchTheme.textPrimary)
                                    .stitchInput(isFocused: !title.isEmpty)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Subject / Academic Module")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(StitchTheme.textPrimary)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        showAddModuleSheet = true
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "plus.circle.fill")
                                            Text("Add Module")
                                        }
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(StitchTheme.primaryGold)
                                    }
                                }
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(modules) { module in
                                            let isSelected = selectedModule?.id == module.id
                                            ModuleChip(module: module, isSelected: isSelected) {
                                                selectedModule = module
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Section: DUE DATE & HOROLOGY
                        VStack(alignment: .leading, spacing: 12) {
                            Text("DUE DATE & HOROLOGY")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(0.8)
                                .foregroundColor(StitchTheme.textSecondary)
                            
                            VStack(spacing: 14) {
                                // Target Date Picker
                                HStack {
                                    HStack(spacing: 10) {
                                        Image(systemName: "calendar")
                                            .foregroundColor(StitchTheme.primaryGold)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Target Date")
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundColor(StitchTheme.textPrimary)
                                            Text("Submission deadline date")
                                                .font(.system(size: 12))
                                                .foregroundColor(StitchTheme.textSecondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    DatePicker("", selection: $dueDate, displayedComponents: [.date])
                                        .labelsHidden()
                                        .colorScheme(.dark)
                                        .tint(StitchTheme.primaryGold)
                                }
                                
                                Divider().background(StitchTheme.borderSubtle)
                                
                                // Exact Time Picker
                                HStack {
                                    HStack(spacing: 10) {
                                        Image(systemName: "clock")
                                            .foregroundColor(StitchTheme.primaryGold)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Exact Time")
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundColor(StitchTheme.textPrimary)
                                            Text("Midnight cut-off window")
                                                .font(.system(size: 12))
                                                .foregroundColor(StitchTheme.textSecondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    DatePicker("", selection: $dueDate, displayedComponents: [.hourAndMinute])
                                        .labelsHidden()
                                        .colorScheme(.dark)
                                        .tint(StitchTheme.primaryGold)
                                }
                                
                                Divider().background(StitchTheme.borderSubtle)
                                
                                // Calculated Window
                                HStack {
                                    HStack(spacing: 10) {
                                        Image(systemName: "hourglass")
                                            .foregroundColor(StitchTheme.primaryGold)
                                        
                                        Text("Calculated Window")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(StitchTheme.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    let days = DateUtilities.daysRemaining(to: dueDate)
                                    Text("\(days) Days Remaining")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(StitchTheme.primaryGold)
                                }
                            }
                            .padding(16)
                            .stitchCard(cornerRadius: 18, background: StitchTheme.cardSurface)
                        }
                        
                        // Section: PRIORITY WEIGHT
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("PRIORITY WEIGHT")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(0.8)
                                    .foregroundColor(StitchTheme.textSecondary)
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(priority.color)
                                        .frame(width: 6, height: 6)
                                    Text(priority == .high ? "High Stake" : (priority == .medium ? "Standard" : "Flexible"))
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(priority.color)
                                }
                            }
                            
                            // Custom Gold-accent segmented selector
                            HStack(spacing: 8) {
                                ForEach(Priority.allCases) { p in
                                    let isSelected = priority == p
                                    Button(action: {
                                        let gen = UISelectionFeedbackGenerator()
                                        gen.selectionChanged()
                                        priority = p
                                    }) {
                                        Text(p.rawValue)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(isSelected ? StitchTheme.canvasBase : StitchTheme.textSecondary)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 44)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                    .fill(isSelected ? StitchTheme.primaryGold : StitchTheme.canvasSecondary)
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                    .stroke(isSelected ? StitchTheme.primaryGold : StitchTheme.borderSubtle, lineWidth: 1)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        
                        // Section: TACTICAL REMINDERS
                        VStack(alignment: .leading, spacing: 12) {
                            Text("TACTICAL REMINDERS")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(0.8)
                                .foregroundColor(StitchTheme.textSecondary)
                            
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    HStack(spacing: 10) {
                                        Image(systemName: "bell.badge.fill")
                                            .foregroundColor(StitchTheme.primaryGold)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Enable Smart Reminder")
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundColor(StitchTheme.textPrimary)
                                            Text("Dynamic cadence as deadline nears")
                                                .font(.system(size: 12))
                                                .foregroundColor(StitchTheme.textSecondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $reminderEnabled)
                                        .labelsHidden()
                                        .tint(StitchTheme.primaryGold)
                                }
                                
                                if reminderEnabled {
                                    Divider().background(StitchTheme.borderSubtle)
                                    
                                    Text("Default Lead Warning")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(StitchTheme.textSecondary)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(ReminderLeadTime.allCases) { lead in
                                                let isSelected = selectedLeadTime == lead
                                                Button(action: {
                                                    selectedLeadTime = lead
                                                }) {
                                                    HStack(spacing: 4) {
                                                        if lead == .custom {
                                                            Image(systemName: "slider.horizontal.3")
                                                        }
                                                        Text(lead.rawValue)
                                                    }
                                                    .font(.system(size: 12, weight: .semibold))
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 8)
                                                    .background(isSelected ? StitchTheme.primaryGold : StitchTheme.canvasSecondary)
                                                    .foregroundColor(isSelected ? StitchTheme.canvasBase : StitchTheme.textSecondary)
                                                    .clipShape(Capsule())
                                                    .overlay(
                                                        Capsule().stroke(isSelected ? StitchTheme.primaryGold : StitchTheme.borderSubtle, lineWidth: 1)
                                                    )
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                    }
                                    
                                    if selectedLeadTime == .custom {
                                        DatePicker("Custom Reminder Date", selection: $customReminderDate)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(StitchTheme.textPrimary)
                                            .colorScheme(.dark)
                                            .tint(StitchTheme.primaryGold)
                                    }
                                }
                            }
                            .padding(16)
                            .stitchCard(cornerRadius: 18, background: StitchTheme.cardSurface)
                        }
                        
                        // Section: ECOSYSTEM INTEGRATION
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ECOSYSTEM INTEGRATION")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(0.8)
                                .foregroundColor(StitchTheme.textSecondary)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    HStack(spacing: 12) {
                                        // Apple Calendar Icon Box
                                        VStack(spacing: 0) {
                                            Text(Date().formatted(.dateTime.month(.abbreviated)).uppercased())
                                                .font(.system(size: 8, weight: .bold))
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 2)
                                                .background(Color.red)
                                            
                                            Text(DateUtilities.dayNumberString(from: Date()))
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(.black)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 2)
                                                .background(Color.white)
                                        }
                                        .frame(width: 32, height: 32)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Add to Apple Calendar")
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundColor(StitchTheme.textPrimary)
                                            Text("Keep personal schedule aligned")
                                                .font(.system(size: 12))
                                                .foregroundColor(StitchTheme.textSecondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $calendarSyncEnabled)
                                        .labelsHidden()
                                        .tint(StitchTheme.primaryGold)
                                        .onChange(of: calendarSyncEnabled) { _, enabled in
                                            if enabled {
                                                Task {
                                                    _ = await CalendarService.shared.requestAccess()
                                                }
                                            }
                                        }
                                }
                                
                                Text("Automatically synchronizes this deadline and alerts to your default iOS Calendar and paired Apple Watch complications.")
                                    .font(.system(size: 12))
                                    .foregroundColor(StitchTheme.textMuted)
                                    .lineSpacing(2)
                            }
                            .padding(16)
                            .stitchCard(cornerRadius: 18, background: StitchTheme.cardSurface)
                        }
                        
                        // Section: BRIEF & DOCUMENTATION
                        VStack(alignment: .leading, spacing: 12) {
                            Text("BRIEF & DOCUMENTATION")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(0.8)
                                .foregroundColor(StitchTheme.textSecondary)
                            
                            VStack(alignment: .leading, spacing: 14) {
                                TextEditor(text: $notes)
                                    .frame(minHeight: 90)
                                    .foregroundColor(StitchTheme.textPrimary)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                                    .overlay(
                                        Group {
                                            if notes.isEmpty {
                                                Text("Add submission link, rubric notes, or partner details...")
                                                    .foregroundColor(StitchTheme.textMuted)
                                                    .padding(.top, 8)
                                                    .padding(.leading, 5)
                                                    .allowsHitTesting(false)
                                            }
                                        },
                                        alignment: .topLeading
                                    )
                                
                                // Attached items list
                                if !pendingAttachments.isEmpty {
                                    VStack(alignment: .leading, spacing: 6) {
                                        ForEach(Array(pendingAttachments.enumerated()), id: \.offset) { index, att in
                                            HStack {
                                                Image(systemName: att.type == "url" ? "link" : "doc.fill")
                                                    .foregroundColor(StitchTheme.primaryGold)
                                                
                                                Text(att.name)
                                                    .font(.system(size: 13, weight: .medium))
                                                    .foregroundColor(StitchTheme.textPrimary)
                                                    .lineLimit(1)
                                                
                                                Spacer()
                                                
                                                Button(action: {
                                                    pendingAttachments.remove(at: index)
                                                }) {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(StitchTheme.textMuted)
                                                }
                                            }
                                            .padding(10)
                                            .background(StitchTheme.canvasSecondary)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                        }
                                    }
                                }
                                
                                HStack(spacing: 12) {
                                    Button(action: {
                                        showFileImporter = true
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "paperclip")
                                                .foregroundColor(StitchTheme.primaryGold)
                                            Text("Attach PDF / Rubric")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(StitchTheme.textPrimary)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 38)
                                        .background(StitchTheme.canvasSecondary)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10).stroke(StitchTheme.borderSubtle, lineWidth: 1)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Button(action: {
                                        showURLAlert = true
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "link")
                                                .foregroundColor(StitchTheme.primaryGold)
                                            Text("Add Canvas URL")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(StitchTheme.textPrimary)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 38)
                                        .background(StitchTheme.canvasSecondary)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10).stroke(StitchTheme.borderSubtle, lineWidth: 1)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(16)
                            .stitchCard(cornerRadius: 18, background: StitchTheme.cardSurface)
                        }
                        
                        // Validation Error Display
                        if let error = validationError {
                            HStack {
                                Image(systemName: "exclamationmark.circle.fill")
                                Text(error)
                            }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(StitchTheme.criticalCoral)
                            .padding(.horizontal)
                        }
                        
                        // Primary CTA
                        VStack(spacing: 8) {
                            GoldButton(title: "Create Deadline", icon: "arrow.right") {
                                saveDeadline()
                            }
                            
                            Text("Encrypted & locally stored on this device")
                                .font(.system(size: 11))
                                .foregroundColor(StitchTheme.textMuted)
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 32)
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(StitchTheme.primaryGold)
                }
                
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Image(systemName: "timer")
                            .foregroundColor(StitchTheme.primaryGold)
                        Text("New Deadline")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(StitchTheme.textPrimary)
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveDeadline()
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(StitchTheme.primaryGold)
                }
            }
            .sheet(isPresented: $showAddModuleSheet) {
                AddModuleSheet { newModule in
                    selectedModule = newModule
                }
            }
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [.pdf, .text, .item],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let sourceURL = urls.first {
                        do {
                            let (relPath, size, name) = try AttachmentService.shared.saveImportedFile(from: sourceURL)
                            pendingAttachments.append((name: name, type: "pdf", path: relPath, url: nil, size: size))
                        } catch {
                            print("File import error: \(error.localizedDescription)")
                        }
                    }
                case .failure(let error):
                    print("File importer failed: \(error.localizedDescription)")
                }
            }
            .alert("Add Resource URL", isPresented: $showURLAlert) {
                TextField("Title (e.g. Canvas Rubric)", text: $urlTitleInput)
                TextField("https://...", text: $urlInput)
                Button("Add") {
                    if !urlInput.isEmpty {
                        let name = urlTitleInput.isEmpty ? "Resource Link" : urlTitleInput
                        pendingAttachments.append((name: name, type: "url", path: nil, url: urlInput, size: 0))
                        urlInput = ""
                        urlTitleInput = ""
                    }
                }
                Button("Cancel", role: .cancel) {
                    urlInput = ""
                    urlTitleInput = ""
                }
            } message: {
                Text("Enter the web URL to Canvas, LMS, or project documentation.")
            }
            .onAppear {
                if let initial = initialDate {
                    dueDate = initial
                }
                if selectedModule == nil, let first = modules.first {
                    selectedModule = first
                }
            }
        }
    }
    
    private func saveDeadline() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            validationError = "Please enter an assignment or milestone title."
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            return
        }
        
        guard let module = selectedModule ?? modules.first else {
            validationError = "Please select or create an academic module."
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            return
        }
        
        let newDeadline = Deadline(
            title: trimmedTitle,
            module: module,
            dueDate: dueDate,
            priority: priority,
            notes: notes,
            workflowStatus: workflowStatus,
            isCompleted: false,
            createdAt: Date(),
            reminderEnabled: reminderEnabled,
            reminderDate: selectedLeadTime == .custom ? customReminderDate : nil,
            reminderLeadTime: selectedLeadTime,
            calendarSyncEnabled: calendarSyncEnabled
        )
        
        // Add pending attachments
        var createdAttachments: [DeadlineAttachment] = []
        for pending in pendingAttachments {
            let att = DeadlineAttachment(
                fileName: pending.name,
                fileType: pending.type,
                localRelativePath: pending.path,
                remoteURL: pending.url,
                fileSizeBytes: pending.size
            )
            att.deadline = newDeadline
            createdAttachments.append(att)
            modelContext.insert(att)
        }
        newDeadline.attachments = createdAttachments
        
        modelContext.insert(newDeadline)
        try? modelContext.save()
        
        // Schedule notification
        NotificationService.shared.scheduleNotification(for: newDeadline)
        
        // Sync to Apple Calendar if enabled
        if calendarSyncEnabled {
            Task {
                if let eventId = await CalendarService.shared.exportOrUpdateEvent(for: newDeadline) {
                    newDeadline.calendarEventIdentifier = eventId
                    try? modelContext.save()
                }
            }
        }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        dismiss()
    }
}
