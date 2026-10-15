//
//  Theme.swift
//  LastMinute
//
//  Design System: Obsidian & Gilded Precision
//  Extracted from Stitch Design Architecture
//

import SwiftUI

// MARK: - Color Extension for Hex Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - LastMinute Design System Colors
struct StitchTheme {
    // Canvas & Layer Depths
    static let canvasBase = Color(hex: "#131313")
    static let canvasSecondary = Color(hex: "#1C1B1B")
    static let cardSurface = Color(hex: "#201F1F")
    static let cardElevated = Color(hex: "#2A2A2A")
    static let cardHighlight = Color(hex: "#353535")
    
    // Gilded Accents
    static let primaryGold = Color(hex: "#F2CC7B")
    static let primaryGoldDark = Color(hex: "#D9AF60")
    static let primaryGoldLight = Color(hex: "#FFEBBA")
    static let secondaryGold = Color(hex: "#ECC06F")
    static let goldContainer = Color(hex: "#694B00")
    
    // Borders & Dividers
    static let borderSubtle = Color(hex: "#3D3D3D")
    static let borderHairline = Color.white.opacity(0.08)
    
    // Semantic States
    static let successMint = Color(hex: "#7BC9A4")
    static let successContainer = Color(hex: "#1C2E24")
    static let criticalCoral = Color(hex: "#E88787")
    static let criticalContainer = Color(hex: "#341E1E")
    static let infoBlue = Color(hex: "#89A9D8")
    static let infoContainer = Color(hex: "#1C2433")
    
    // Typography
    static let textPrimary = Color(hex: "#FFFFFF")
    static let textSecondary = Color(hex: "#A6A6A6")
    static let textMuted = Color(hex: "#747877")
    
    // Gradients
    static let heroGoldGradient = LinearGradient(
        colors: [Color(hex: "#F2CC7B").opacity(0.18), Color.clear],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let primaryGoldButtonGradient = LinearGradient(
        colors: [Color(hex: "#F8D78E"), Color(hex: "#E7BE6A")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let countdownElapsedGradient = LinearGradient(
        colors: [Color(hex: "#D9AF60"), Color(hex: "#F2CC7B")],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - Custom View Modifiers

struct StitchCardModifier: ViewModifier {
    var isUrgent: Bool = false
    var cornerRadius: CGFloat = 22
    var background: Color = StitchTheme.cardSurface

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(isUrgent ? StitchTheme.primaryGold.opacity(0.4) : StitchTheme.borderSubtle, lineWidth: 1)
            )
            .shadow(
                color: isUrgent ? StitchTheme.primaryGold.opacity(0.15) : Color.black.opacity(0.4),
                radius: isUrgent ? 16 : 8,
                x: 0,
                y: isUrgent ? 4 : 2
            )
    }
}

struct StitchInputModifier: ViewModifier {
    var isFocused: Bool = false
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(StitchTheme.canvasSecondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isFocused ? StitchTheme.primaryGold.opacity(0.8) : StitchTheme.borderSubtle, lineWidth: 1)
            )
    }
}

struct GildedGlowModifier: ViewModifier {
    var radius: CGFloat = 20
    var opacity: Double = 0.25
    
    func body(content: Content) -> some View {
        content
            .shadow(color: StitchTheme.primaryGold.opacity(opacity), radius: radius, x: 0, y: 4)
    }
}

extension View {
    func stitchCard(isUrgent: Bool = false, cornerRadius: CGFloat = 22, background: Color = StitchTheme.cardSurface) -> some View {
        modifier(StitchCardModifier(isUrgent: isUrgent, cornerRadius: cornerRadius, background: background))
    }
    
    func stitchInput(isFocused: Bool = false) -> some View {
        modifier(StitchInputModifier(isFocused: isFocused))
    }
    
    func gildedGlow(radius: CGFloat = 20, opacity: Double = 0.25) -> some View {
        modifier(GildedGlowModifier(radius: radius, opacity: opacity))
    }
}
