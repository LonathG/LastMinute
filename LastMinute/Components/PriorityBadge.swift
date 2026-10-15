//
//  PriorityBadge.swift
//  LastMinute
//

import SwiftUI

struct PriorityBadge: View {
    let priority: Priority
    var showDot: Bool = true
    
    var body: some View {
        HStack(spacing: 5) {
            if showDot {
                Circle()
                    .fill(priority.color)
                    .frame(width: 6, height: 6)
            }
            Text(priority.rawValue.uppercased() + " PRIORITY")
                .font(.system(size: 10, weight: .bold))
                .tracking(0.6)
                .foregroundColor(priority.color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(priority.containerColor)
        .overlay(
            Capsule()
                .stroke(priority.color.opacity(0.3), lineWidth: 1)
        )
        .clipShape(Capsule())
    }
}
