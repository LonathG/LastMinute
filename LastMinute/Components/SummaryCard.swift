//
//  SummaryCard.swift
//  LastMinute
//

import SwiftUI

struct SummaryCard: View {
    let icon: String
    let dotColor: Color
    let count: Int
    let label: String
    var countColor: Color = StitchTheme.textPrimary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(StitchTheme.textSecondary)
                
                Spacer()
                
                Circle()
                    .fill(dotColor)
                    .frame(width: 6, height: 6)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(String(format: "%02d", count))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(countColor)
                
                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.6)
                    .foregroundColor(StitchTheme.textSecondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .stitchCard(isUrgent: false, cornerRadius: 18, background: StitchTheme.cardSurface)
    }
}
