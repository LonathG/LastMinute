//
//  DeadlineAttachment.swift
//  LastMinute
//

import Foundation
import SwiftData

@Model
final class DeadlineAttachment {
    var id: UUID = UUID()
    var fileName: String = ""
    var fileType: String = "pdf" // "pdf", "url", "image", "doc"
    var localRelativePath: String? = nil
    var remoteURL: String? = nil
    var fileSizeBytes: Int64 = 0
    var createdAt: Date = Date()
    
    var deadline: Deadline?
    
    init(
        id: UUID = UUID(),
        fileName: String,
        fileType: String = "pdf",
        localRelativePath: String? = nil,
        remoteURL: String? = nil,
        fileSizeBytes: Int64 = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.fileName = fileName
        self.fileType = fileType
        self.localRelativePath = localRelativePath
        self.remoteURL = remoteURL
        self.fileSizeBytes = fileSizeBytes
        self.createdAt = createdAt
    }
    
    var isWebURL: Bool {
        return fileType == "url" || (remoteURL != nil && !remoteURL!.isEmpty)
    }
    
    var formattedFileSize: String {
        guard fileSizeBytes > 0 else { return "" }
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSizeBytes)
    }
}
