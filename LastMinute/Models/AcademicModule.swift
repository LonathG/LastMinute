//
//  AcademicModule.swift
//  LastMinute
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class AcademicModule {
    var id: UUID = UUID()
    var code: String = ""
    var name: String = ""
    var shortLabel: String = ""
    var colorHex: String = "#F2CC7B"
    var createdAt: Date = Date()
    
    @Relationship(inverse: \Deadline.module)
    var deadlines: [Deadline]? = []
    
    init(
        id: UUID = UUID(),
        code: String,
        name: String,
        shortLabel: String = "",
        colorHex: String = "#F2CC7B",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.code = code
        self.name = name
        self.shortLabel = shortLabel.isEmpty ? code : shortLabel
        self.colorHex = colorHex
        self.createdAt = createdAt
    }
    
    var color: Color {
        Color(hex: colorHex)
    }
    
    var displayChipTitle: String {
        if shortLabel.isEmpty || shortLabel == code {
            return "\(code) — \(name)"
        }
        return "\(code) — \(shortLabel)"
    }
}
