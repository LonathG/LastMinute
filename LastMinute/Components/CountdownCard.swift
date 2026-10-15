//
//  CountdownCard.swift
//  LastMinute
//

import SwiftUI

struct CountdownCard: View {
    let deadline: Deadline
    var onViewDetails: (() -> Void)? = nil
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            let components = deadline.timeComponents
            
            VStack(alignment: .leading, spacing: 0) {
                // Top Badges Row
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(StitchTheme.primaryGold)
                            .frame(width: 7, height: 7)
                            .shadow(color: StitchTheme.primaryGold, radius: 4)
                        
                        Text("NEXT DEADLINE • URGENT")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(0.8)
                            .foregroundColor(StitchTheme.primaryGold)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(StitchTheme.cardSurface)
                    .clipShape(Capsule())
                    
                    Spacer()
                    
                    PriorityBadge(priority: deadline.priority)
                }
                .padding(.bottom, 14)
                
                // Title and Module
                VStack(alignment: .leading, spacing: 4) {
                    Text(deadline.title)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(StitchTheme.textPrimary)
                        .lineLimit(2)
                    
                    Text(deadline.module?.displayChipTitle ?? "Academic Milestone")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(StitchTheme.textSecondary)
                }
                .padding(.bottom, 16)
                
                // 4 Inset Countdown Boxes
                HStack(spacing: 8) {
                    CountdownDigitBox(value: String(format: "%02d", components.days), unit: "DAYS")
                    CountdownDigitBox(value: String(format: "%02d", components.hours), unit: "HOURS")
                    CountdownDigitBox(value: String(format: "%02d", components.minutes), unit: "MIN")
                    CountdownDigitBox(value: String(format: "%02d", components.seconds), unit: "SEC")
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(StitchTheme.canvasSecondary)
                )
                .padding(.bottom, 16)
                
                // Bottom Row: Due Date & View Details
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(StitchTheme.primaryGold)
                        
                        Text("Due: \(deadline.formattedDueDate)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(StitchTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        onViewDetails?()
                    }) {
                        HStack(spacing: 4) {
                            Text("View Details")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(StitchTheme.primaryGold)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(StitchTheme.primaryGold)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
            .stitchCard(isUrgent: true, cornerRadius: 22, background: StitchTheme.cardElevated)
        }
    }
}

struct CountdownDigitBox: View {
    let value: String
    let unit: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundColor(StitchTheme.primaryGold)
                .lineLimit(1)
            
            Text(unit)
                .font(.system(size: 10, weight: .bold))
                .tracking(0.6)
                .foregroundColor(StitchTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(StitchTheme.cardSurface)
        )
    }
}
