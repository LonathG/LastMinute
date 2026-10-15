//
//  ProgressRing.swift
//  LastMinute
//

import SwiftUI

struct ProgressRing: View {
    let percentage: Int // 0 - 100
    let completedCount: Int
    let totalCount: Int
    
    @State private var animatedPercentage: Double = 0.0
    
    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                // Background Ambient Glow
                Circle()
                    .fill(StitchTheme.primaryGold.opacity(0.08))
                    .frame(width: 190, height: 190)
                    .blur(radius: 20)
                
                // Track
                Circle()
                    .stroke(StitchTheme.cardHighlight, lineWidth: 16)
                    .frame(width: 170, height: 170)
                
                // Progress Arc
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(animatedPercentage, 1.0)))
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                StitchTheme.primaryGoldDark,
                                StitchTheme.primaryGold,
                                StitchTheme.primaryGoldLight
                            ]),
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 170, height: 170)
                    .shadow(color: StitchTheme.primaryGold.opacity(0.3), radius: 8, x: 0, y: 0)
                
                // Center Numbers
                VStack(spacing: 2) {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(Int(animatedPercentage * 100))")
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundColor(StitchTheme.textPrimary)
                        
                        Text("%")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(StitchTheme.primaryGold)
                    }
                    
                    Text("COMPLETION RATE")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.0)
                        .foregroundColor(StitchTheme.textSecondary)
                }
            }
            .padding(.top, 10)
            
            // Sub-pill description
            HStack(spacing: 6) {
                Circle()
                    .fill(StitchTheme.successMint)
                    .frame(width: 6, height: 6)
                
                Text("\(completedCount) of \(totalCount) deadlines completed")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(StitchTheme.textPrimary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(StitchTheme.cardElevated)
            .overlay(
                Capsule()
                    .stroke(StitchTheme.borderSubtle, lineWidth: 1)
            )
            .clipShape(Capsule())
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .stitchCard(isUrgent: false, cornerRadius: 24, background: StitchTheme.cardSurface)
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                animatedPercentage = Double(percentage) / 100.0
            }
        }
        .onChange(of: percentage) { oldValue, newValue in
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                animatedPercentage = Double(newValue) / 100.0
            }
        }
    }
}
