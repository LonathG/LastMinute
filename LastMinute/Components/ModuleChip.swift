//
//  ModuleChip.swift
//  LastMinute
//

import SwiftUI

struct ModuleChip: View {
    let module: AcademicModule
    var isSelected: Bool = false
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(spacing: 6) {
                Circle()
                    .fill(module.color)
                    .frame(width: 8, height: 8)
                
                Text(module.displayChipTitle)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isSelected ? StitchTheme.canvasBase : StitchTheme.textPrimary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? StitchTheme.primaryGold : StitchTheme.cardElevated)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? StitchTheme.primaryGold : StitchTheme.borderSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
