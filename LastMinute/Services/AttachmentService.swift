//
//  AttachmentService.swift
//  LastMinute
//

import Foundation

final class AttachmentService {
    static let shared = AttachmentService()
    
    private let fileManager = FileManager.default
    
    private var attachmentsDirectory: URL {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let docDir = paths[0]
        let attachDir = docDir.appendingPathComponent("Attachments", isDirectory: true)
        if !fileManager.fileExists(atPath: attachDir.path) {
            try? fileManager.createDirectory(at: attachDir, withIntermediateDirectories: true)
        }
        return attachDir
    }
    
    func saveImportedFile(from sourceURL: URL) throws -> (relativePath: String, sizeBytes: Int64, fileName: String) {
        let isScoped = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if isScoped {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }
        
        let originalName = sourceURL.lastPathComponent
        let uniquePrefix = UUID().uuidString.prefix(8)
        let destinationFileName = "\(uniquePrefix)_\(originalName)"
        let destinationURL = attachmentsDirectory.appendingPathComponent(destinationFileName)
        
        if fileManager.fileExists(atPath: destinationURL.path) {
            try? fileManager.removeItem(at: destinationURL)
        }
        
        try fileManager.copyItem(at: sourceURL, to: destinationURL)
        
        let attributes = try fileManager.attributesOfItem(atPath: destinationURL.path)
        let size = attributes[.size] as? Int64 ?? 0
        
        let relativePath = "Attachments/\(destinationFileName)"
        return (relativePath, size, originalName)
    }
    
    func fullURL(for relativePath: String) -> URL? {
        let docDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = docDir.appendingPathComponent(relativePath)
        if fileManager.fileExists(atPath: fileURL.path) {
            return fileURL
        }
        return nil
    }
    
    func deleteFile(at relativePath: String?) {
        guard let relativePath = relativePath, !relativePath.isEmpty else { return }
        let docDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = docDir.appendingPathComponent(relativePath)
        try? fileManager.removeItem(at: fileURL)
    }
}
