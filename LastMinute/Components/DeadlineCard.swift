//
//  DeadlineCard.swift
//  LastMinute
//

import SwiftUI

struct DeadlineCard: View {
    let deadline: Deadline
    var onToggleComplete: (() -> Void)? = nil
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            HStack(alignment: .center, spacing: 14) {
                // Circular Checkbox / Completion trigger
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    onToggleComplete?()
                }) {
                    ZStack {
                        Circle()
                            .fill(deadline.isCompleted ? StitchTheme.successMint : StitchTheme.canvasSecondary)
                            .frame(width: 28, height: 28)
                            .overlay(
                                Circle()
                                    .stroke(deadline.isCompleted ? StitchTheme.successMint : StitchTheme.borderSubtle, lineWidth: 1.5)
                            )
                        
                        if deadline.isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(StitchTheme.canvasBase)
                        }
                    }
                }
                .buttonStyle(.plain)
                
                // Content
                VStack(alignment: .leading, spacing: 5) {
                    // Category Chip & Time Left Row
                    HStack(spacing: 8) {
                        if let module = deadline.module {
                            Text(module.shortLabel.isEmpty ? module.code : module.shortLabel)
                                .font(.system(size: 11, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(module.color.opacity(0.18))
                                .foregroundColor(module.color)
                                .clipShape(Capsule())
                        }
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(deadline.isOverdue ? StitchTheme.criticalCoral : StitchTheme.primaryGold)
                                .frame(width: 5, height: 5)
                            
                            Text(deadline.formattedRemainingShort)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(deadline.isOverdue ? StitchTheme.criticalCoral : StitchTheme.textSecondary)
                        }
                        
                        Spacer()
                    }
                    
                    // Title
                    Text(deadline.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(deadline.isCompleted ? StitchTheme.textSecondary : StitchTheme.textPrimary)
                        .strikethrough(deadline.isCompleted, color: StitchTheme.textSecondary)
                        .lineLimit(1)
                    
                    // Due Date Info
                    Text(DateUtilities.relativeDueString(for: deadline.dueDate))
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(StitchTheme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(StitchTheme.borderSubtle)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .stitchCard(isUrgent: deadline.isNextUrgent, cornerRadius: 18, background: StitchTheme.cardSurface)
        }
        .buttonStyle(.plain)
    }
}
