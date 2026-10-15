//
//  EditDeadlineView.swift
//  LastMinute
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct EditDeadlineView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AcademicModule.code) private var modules: [AcademicModule]
    
    @Bindable var deadline: Deadline
    
    // Form States initialized from deadline
    @State private var title: String
    @State private var selectedModule: AcademicModule?
    @State private var dueDate: Date
    @State private var priority: Priority
    @State private var workflowStatus: WorkflowStatus
    @State private var notes: String
    
    @State private var reminderEnabled: Bool
    @State private var selectedLeadTime: ReminderLeadTime
    @State private var customReminderDate: Date
    @State private var calendarSyncEnabled: Bool
    
    @State private var showFileImporter: Bool = false
    @State private var showURLAlert: Bool = false
    @State private var urlInput: String = ""
    @State private var urlTitleInput: String = ""
    @State private var showAddModuleSheet: Bool = false
    @State private var validationError: String? = nil
    
    init(deadline: Deadline) {
        self.deadline = deadline
        _title = State(initialValue: deadline.title)
        _selectedModule = State(initialValue: deadline.module)
        _dueDate = State(initialValue: deadline.dueDate)
        _priority = State(initialValue: deadline.priority)
        _workflowStatus = State(initialValue: deadline.workflowStatus)
        _notes = State(initialValue: deadline.notes)
        _reminderEnabled = State(initialValue: deadline.reminderEnabled)
        _selectedLeadTime = State(initialValue: deadline.reminderLeadTime ?? .oneDayBefore)
        _customReminderDate = State(initialValue: deadline.reminderDate ?? Date().addingTimeInterval(86400))
        _calendarSyncEnabled = State(initialValue: deadline.calendarSyncEnabled)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                StitchTheme.canvasBase.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Title & Module
                        VStack(alignment: .leading, spacing: 14) {
                            Text("GENERAL INFORMATION")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(0.8)
                                .foregroundColor(StitchTheme.textSecondary)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Assignment / Milestone Title")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(StitchTheme.textPrimary)
                                
                                TextField("Title", text: $title)
                                    .foregroundColor(StitchTheme.textPrimary)
                                    .stitchInput(isFocused: true)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Academic Module")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(StitchTheme.textPrimary)
                                    
                                    Spacer()
                                    
                                    Button(action: { showAddModuleSheet = true }) {
                                        Text("+ Add Module")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(StitchTheme.primaryGold)
                                    }
                                }
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(modules) { mod in
                                            let isSelected = selectedModule?.id == mod.id
                                            ModuleChip(module: mod, isSelected: isSelected) {
                                                selectedModule = mod
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Due Date & Time
                        VStack(alignment: .leading, spacing: 12) {
                            Text("DUE DATE & HOROLOGY")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(0.8)
                                .foregroundColor(StitchTheme.textSecondary)
                            
                            VStack(spacing: 14) {
                                HStack {
                                    Text("Target Date")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(StitchTheme.textPrimary)
                                    Spacer()
                                    DatePicker("", selection: $dueDate, displayedComponents: [.date])
                                        .labelsHidden()
                                        .colorScheme(.dark)
                                        .tint(StitchTheme.primaryGold)
                                }
                                
                                Divider().background(StitchTheme.borderSubtle)
                                
                                HStack {
                                    Text("Exact Time")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(StitchTheme.textPrimary)
                                    Spacer()
                                    DatePicker("", selection: $dueDate, displayedComponents: [.hourAndMinute])
                                        .labelsHidden()
                                        .colorScheme(.dark)
                                        .tint(StitchTheme.primaryGold)
                                }
                            }
                            .padding(16)
                            .stitchCard(cornerRadius: 18, background: StitchTheme.cardSurface)
                        }
                        
                        // Priority
                        VStack(alignment: .leading, spacing: 12) {
                            Text("PRIORITY WEIGHT")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(0.8)
                                .foregroundColor(StitchTheme.textSecondary)
                            
                            HStack(spacing: 8) {
                                ForEach(Priority.allCases) { p in
                                    let isSelected = priority == p
                                    Button(action: { priority = p }) {
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
                        
                        // Workflow Status
                        VStack(alignment: .leading, spacing: 12) {
                            Text("WORKFLOW STATE")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(0.8)
                                .foregroundColor(StitchTheme.textSecondary)
                            
                            HStack(spacing: 8) {
                                ForEach(WorkflowStatus.allCases) { st in
                                    let isSelected = workflowStatus == st
                                    Button(action: { workflowStatus = st }) {
                                        Text(st.rawValue)
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(isSelected ? StitchTheme.canvasBase : StitchTheme.textSecondary)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 40)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .fill(isSelected ? StitchTheme.primaryGold : StitchTheme.canvasSecondary)
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .stroke(isSelected ? StitchTheme.primaryGold : StitchTheme.borderSubtle, lineWidth: 1)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        
                        // Reminders
                        VStack(alignment: .leading, spacing: 12) {
                            Text("TACTICAL REMINDERS")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(0.8)
                                .foregroundColor(StitchTheme.textSecondary)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Toggle("Enable Smart Reminder", isOn: $reminderEnabled)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(StitchTheme.textPrimary)
                                    .tint(StitchTheme.primaryGold)
                                
                                if reminderEnabled {
                                    Divider().background(StitchTheme.borderSubtle)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(ReminderLeadTime.allCases) { lead in
                                                let isSelected = selectedLeadTime == lead
                                                Button(action: { selectedLeadTime = lead }) {
                                                    Text(lead.rawValue)
                                                        .font(.system(size: 12, weight: .semibold))
                                                        .padding(.horizontal, 12)
                                                        .padding(.vertical, 8)
                                                        .background(isSelected ? StitchTheme.primaryGold : StitchTheme.canvasSecondary)
                                                        .foregroundColor(isSelected ? StitchTheme.canvasBase : StitchTheme.textSecondary)
                                                        .clipShape(Capsule())
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(16)
                            .stitchCard(cornerRadius: 18, background: StitchTheme.cardSurface)
                        }
                        
                        // Apple Calendar
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ECOSYSTEM INTEGRATION")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(0.8)
                                .foregroundColor(StitchTheme.textSecondary)
                            
                            Toggle("Sync to Apple Calendar", isOn: $calendarSyncEnabled)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(StitchTheme.textPrimary)
                                .tint(StitchTheme.primaryGold)
                                .padding(16)
                                .stitchCard(cornerRadius: 18, background: StitchTheme.cardSurface)
                        }
                        
                        // Notes & Attachments
                        VStack(alignment: .leading, spacing: 12) {
                            Text("BRIEF & DOCUMENTATION")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(0.8)
                                .foregroundColor(StitchTheme.textSecondary)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                TextEditor(text: $notes)
                                    .frame(minHeight: 80)
                                    .foregroundColor(StitchTheme.textPrimary)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                                
                                // Existing attachments
                                if let atts = deadline.attachments, !atts.isEmpty {
                                    VStack(alignment: .leading, spacing: 6) {
                                        ForEach(atts) { att in
                                            HStack {
                                                Image(systemName: att.isWebURL ? "link" : "doc.fill")
                                                    .foregroundColor(StitchTheme.primaryGold)
                                                Text(att.fileName)
                                                    .font(.system(size: 13, weight: .medium))
                                                    .foregroundColor(StitchTheme.textPrimary)
                                                    .lineLimit(1)
                                                Spacer()
                                                Button(action: {
                                                    AttachmentService.shared.deleteFile(at: att.localRelativePath)
                                                    modelContext.delete(att)
                                                    try? modelContext.save()
                                                }) {
                                                    Image(systemName: "trash")
                                                        .font(.system(size: 13))
                                                        .foregroundColor(StitchTheme.criticalCoral)
                                                }
                                            }
                                            .padding(10)
                                            .background(StitchTheme.canvasSecondary)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                        }
                                    }
                                }
                                
                                HStack(spacing: 12) {
                                    Button(action: { showFileImporter = true }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "paperclip")
                                                .foregroundColor(StitchTheme.primaryGold)
                                            Text("Attach Document")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(StitchTheme.textPrimary)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 38)
                                        .background(StitchTheme.canvasSecondary)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Button(action: { showURLAlert = true }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "link")
                                                .foregroundColor(StitchTheme.primaryGold)
                                            Text("Add URL")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(StitchTheme.textPrimary)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 38)
                                        .background(StitchTheme.canvasSecondary)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(16)
                            .stitchCard(cornerRadius: 18, background: StitchTheme.cardSurface)
                        }
                        
                        // Validation error
                        if let err = validationError {
                            Text(err)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(StitchTheme.criticalCoral)
                        }
                        
                        GoldButton(title: "Save Changes") {
                            applyChanges()
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 32)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Edit Deadline")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(StitchTheme.primaryGold)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { applyChanges() }
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(StitchTheme.primaryGold)
                }
            }
            .sheet(isPresented: $showAddModuleSheet) {
                AddModuleSheet { mod in
                    selectedModule = mod
                }
            }
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [.pdf, .text, .item],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let src = urls.first {
                        do {
                            let (rel, size, name) = try AttachmentService.shared.saveImportedFile(from: src)
                            let newAtt = DeadlineAttachment(fileName: name, fileType: "pdf", localRelativePath: rel, fileSizeBytes: size)
                            newAtt.deadline = deadline
                            modelContext.insert(newAtt)
                            try? modelContext.save()
                        } catch {
                            print("Error attaching file: \(error.localizedDescription)")
                        }
                    }
                case .failure(let err):
                    print("File import failed: \(err.localizedDescription)")
                }
            }
            .alert("Add Resource URL", isPresented: $showURLAlert) {
                TextField("Title", text: $urlTitleInput)
                TextField("URL", text: $urlInput)
                Button("Add") {
                    if !urlInput.isEmpty {
                        let name = urlTitleInput.isEmpty ? "Resource Link" : urlTitleInput
                        let newAtt = DeadlineAttachment(fileName: name, fileType: "url", remoteURL: urlInput)
                        newAtt.deadline = deadline
                        modelContext.insert(newAtt)
                        try? modelContext.save()
                        urlInput = ""
                        urlTitleInput = ""
                    }
                }
                Button("Cancel", role: .cancel) {
                    urlInput = ""
                    urlTitleInput = ""
                }
            }
        }
    }
    
    private func applyChanges() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            validationError = "Title cannot be empty."
            return
        }
        
        deadline.title = trimmed
        deadline.module = selectedModule
        deadline.dueDate = dueDate
        deadline.priority = priority
        deadline.workflowStatus = workflowStatus
        deadline.notes = notes
        deadline.reminderEnabled = reminderEnabled
        deadline.reminderDate = selectedLeadTime == .custom ? customReminderDate : nil
        deadline.reminderLeadTime = selectedLeadTime
        deadline.calendarSyncEnabled = calendarSyncEnabled
        
        try? modelContext.save()
        
        // Update notifications
        NotificationService.shared.scheduleNotification(for: deadline)
        
        // Update Apple Calendar
        if calendarSyncEnabled {
            Task {
                if let eventId = await CalendarService.shared.exportOrUpdateEvent(for: deadline) {
                    deadline.calendarEventIdentifier = eventId
                    try? modelContext.save()
                }
            }
        } else if let id = deadline.calendarEventIdentifier {
            CalendarService.shared.removeEvent(identifier: id)
            deadline.calendarEventIdentifier = nil
            try? modelContext.save()
        }
        
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(.success)
        dismiss()
    }
}
