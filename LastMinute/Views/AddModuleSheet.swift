//
//  AddModuleSheet.swift
//  LastMinute
//

import SwiftUI
import SwiftData

struct AddModuleSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var code: String = ""
    @State private var name: String = ""
    @State private var shortLabel: String = ""
    @State private var selectedColorHex: String = "#F2CC7B"
    @State private var errorMessage: String? = nil
    
    let colorPalette: [String] = [
        "#F2CC7B", // Gold
        "#7BC9A4", // Mint Green
        "#89A9D8", // Slate Blue
        "#E88787", // Coral Red
        "#C59BEE", // Purple
        "#ECC06F", // Amber
        "#64D2B8", // Cyan Teal
        "#FF9F67"  // Orange
    ]
    
    var onCreated: ((AcademicModule) -> Void)? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                StitchTheme.canvasBase.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        // Header Guidance
                        VStack(alignment: .leading, spacing: 4) {
                            Text("New Academic Module")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(StitchTheme.textPrimary)
                            
                            Text("Create a course or subject to organize upcoming submissions.")
                                .font(.system(size: 14))
                                .foregroundColor(StitchTheme.textSecondary)
                        }
                        .padding(.top, 8)
                        
                        // Fields
                        VStack(alignment: .leading, spacing: 8) {
                            Text("MODULE CODE")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(0.6)
                                .foregroundColor(StitchTheme.textSecondary)
                            
                            TextField("e.g. SE4041", text: $code)
                                .textInputAutocapitalization(.characters)
                                .foregroundColor(StitchTheme.textPrimary)
                                .stitchInput()
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("MODULE TITLE / NAME")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(0.6)
                                .foregroundColor(StitchTheme.textSecondary)
                            
                            TextField("e.g. Mobile Application Development", text: $name)
                                .foregroundColor(StitchTheme.textPrimary)
                                .stitchInput()
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("SHORT TAG / ACRONYM")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(0.6)
                                .foregroundColor(StitchTheme.textSecondary)
                            
                            TextField("e.g. MADD", text: $shortLabel)
                                .textInputAutocapitalization(.characters)
                                .foregroundColor(StitchTheme.textPrimary)
                                .stitchInput()
                        }
                        
                        // Color Selection
                        VStack(alignment: .leading, spacing: 10) {
                            Text("ACCENT COLOR")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(0.6)
                                .foregroundColor(StitchTheme.textSecondary)
                            
                            HStack(spacing: 12) {
                                ForEach(colorPalette, id: \.self) { hex in
                                    let isSelected = (selectedColorHex.lowercased() == hex.lowercased())
                                    Circle()
                                        .fill(Color(hex: hex))
                                        .frame(width: 34, height: 34)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: isSelected ? 2.5 : 0)
                                        )
                                        .shadow(color: isSelected ? Color(hex: hex).opacity(0.5) : Color.clear, radius: 6)
                                        .onTapGesture {
                                            selectedColorHex = hex
                                        }
                                }
                            }
                        }
                        
                        // Error message if any
                        if let error = errorMessage {
                            Text(error)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(StitchTheme.criticalCoral)
                        }
                        
                        Spacer(minLength: 20)
                        
                        GoldButton(title: "Save Academic Module") {
                            saveModule()
                        }
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
                    .foregroundColor(StitchTheme.primaryGold)
                }
            }
        }
    }
    
    private func saveModule() {
        let trimmedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedCode.isEmpty else {
            errorMessage = "Please provide a valid module code."
            return
        }
        guard !trimmedName.isEmpty else {
            errorMessage = "Please enter the course name."
            return
        }
        
        let newModule = AcademicModule(
            code: trimmedCode,
            name: trimmedName,
            shortLabel: shortLabel.trimmingCharacters(in: .whitespacesAndNewlines),
            colorHex: selectedColorHex
        )
        
        modelContext.insert(newModule)
        try? modelContext.save()
        onCreated?(newModule)
        dismiss()
    }
}
