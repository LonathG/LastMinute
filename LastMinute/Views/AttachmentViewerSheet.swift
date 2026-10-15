//
//  AttachmentViewerSheet.swift
//  LastMinute
//

import SwiftUI
import PDFKit

struct AttachmentViewerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let attachment: DeadlineAttachment
    
    var body: some View {
        NavigationStack {
            ZStack {
                StitchTheme.canvasBase.ignoresSafeArea()
                
                if attachment.isWebURL, let urlString = attachment.remoteURL, let url = URL(string: urlString) {
                    VStack(spacing: 24) {
                        Image(systemName: "link.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(StitchTheme.primaryGold)
                        
                        VStack(spacing: 8) {
                            Text(attachment.fileName)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(StitchTheme.textPrimary)
                            
                            Text(urlString)
                                .font(.system(size: 14))
                                .foregroundColor(StitchTheme.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        Link(destination: url) {
                            HStack(spacing: 8) {
                                Image(systemName: "safari")
                                Text("Open Link in Browser")
                            }
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(StitchTheme.canvasBase)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Capsule().fill(StitchTheme.primaryGold))
                            .padding(.horizontal, 32)
                        }
                    }
                    .padding()
                } else if let relativePath = attachment.localRelativePath,
                          let fileURL = AttachmentService.shared.fullURL(for: relativePath) {
                    PDFKitRepresentable(url: fileURL)
                        .ignoresSafeArea(edges: .bottom)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(StitchTheme.criticalCoral)
                        
                        Text("Attachment file not found")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(StitchTheme.textPrimary)
                    }
                }
            }
            .navigationTitle(attachment.fileName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(StitchTheme.primaryGold)
                }
            }
        }
    }
}

struct PDFKitRepresentable: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: url)
        pdfView.autoScales = true
        pdfView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {}
}
