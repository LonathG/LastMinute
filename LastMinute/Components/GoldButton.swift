//
//  GoldButton.swift
//  LastMinute
//

import SwiftUI

struct GoldButton: View {
    let title: String
    var icon: String? = nil
    var isEnabled: Bool = true
    var action: () -> Void
    
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(StitchTheme.canvasBase)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                Capsule()
                    .fill(isEnabled ? StitchTheme.primaryGoldButtonGradient : LinearGradient(colors: [Color.gray, Color.gray.opacity(0.8)], startPoint: .top, endPoint: .bottom))
            )
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .gildedGlow(radius: 12, opacity: isEnabled ? 0.35 : 0)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .opacity(isEnabled ? (isPressed ? 0.9 : 1.0) : 0.5)
        }
        .disabled(!isEnabled)
        .buttonStyle(PlainPressableButtonStyle(isPressed: $isPressed))
    }
}

struct SecondaryCardButton: View {
    let title: String
    var icon: String? = nil
    var isDestructive: Bool = false
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(isDestructive ? StitchTheme.criticalCoral : StitchTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isDestructive ? StitchTheme.criticalContainer.opacity(0.5) : StitchTheme.cardSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isDestructive ? StitchTheme.criticalCoral.opacity(0.3) : StitchTheme.borderSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct FloatingAddButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            action()
        }) {
            ZStack {
                Circle()
                    .fill(StitchTheme.primaryGold)
                    .frame(width: 58, height: 58)
                    .gildedGlow(radius: 16, opacity: 0.5)
                
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(StitchTheme.canvasBase)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct PlainPressableButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newVal in
                isPressed = newVal
            }
    }
}
