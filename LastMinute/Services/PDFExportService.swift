//
//  PDFExportService.swift
//  LastMinute
//

import UIKit
import PDFKit

final class PDFExportService {
    static let shared = PDFExportService()
    
    func generateSemesterSummaryPDF(deadlines: [Deadline], stats: SemesterStats) -> URL? {
        let pageWidth: CGFloat = 612 // Standard US Letter width
        let pageHeight: CGFloat = 792 // Standard US Letter height
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("LastMinute_Semester_Summary.pdf")
        
        do {
            try renderer.writePDF(to: tempURL) { context in
                context.beginPage()
                let cgContext = context.cgContext
                
                // Background
                cgContext.setFillColor(UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1.0).cgColor)
                cgContext.fill(pageRect)
                
                // Top Header Bar
                let headerRect = CGRect(x: 36, y: 36, width: pageWidth - 72, height: 70)
                cgContext.setFillColor(UIColor(red: 0.13, green: 0.12, blue: 0.12, alpha: 1.0).cgColor)
                let headerPath = UIBezierPath(roundedRect: headerRect, cornerRadius: 12)
                headerPath.fill()
                
                // Header Gold Accent Bar
                cgContext.setFillColor(UIColor(red: 0.95, green: 0.80, blue: 0.48, alpha: 1.0).cgColor)
                let accentBar = CGRect(x: 36, y: 36, width: 6, height: 70)
                UIBezierPath(roundedRect: accentBar, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: 12, height: 12)).fill()
                
                // Header Title Text
                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 20, weight: .bold),
                    .foregroundColor: UIColor.white
                ]
                "LASTMINUTE — Semester Summary Report".draw(at: CGPoint(x: 54, y: 48), withAttributes: titleAttributes)
                
                let dateStr = "Generated on \(Date().formatted(date: .long, time: .shortened))"
                let dateAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 11, weight: .medium),
                    .foregroundColor: UIColor(red: 0.95, green: 0.80, blue: 0.48, alpha: 1.0)
                ]
                dateStr.draw(at: CGPoint(x: 54, y: 74), withAttributes: dateAttributes)
                
                // 4 Metric Highlight Cards
                let cardY: CGFloat = 122
                let cardW: CGFloat = (pageWidth - 72 - 36) / 4
                let cardH: CGFloat = 64
                
                let kpis: [(title: String, val: String, color: UIColor)] = [
                    ("TOTAL", "\(stats.totalCount)", .white),
                    ("COMPLETED", "\(stats.completedCount)", UIColor(red: 0.48, green: 0.79, blue: 0.64, alpha: 1.0)),
                    ("PENDING", "\(stats.pendingCount)", UIColor(red: 0.95, green: 0.80, blue: 0.48, alpha: 1.0)),
                    ("OVERDUE", "\(stats.overdueCount)", UIColor(red: 0.91, green: 0.53, blue: 0.53, alpha: 1.0))
                ]
                
                for (i, kpi) in kpis.enumerated() {
                    let rect = CGRect(x: 36 + CGFloat(i) * (cardW + 12), y: cardY, width: cardW, height: cardH)
                    cgContext.setFillColor(UIColor(red: 0.14, green: 0.14, blue: 0.14, alpha: 1.0).cgColor)
                    UIBezierPath(roundedRect: rect, cornerRadius: 10).fill()
                    
                    let kTitleAttr: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
                        .foregroundColor: UIColor.lightGray
                    ]
                    kpi.title.draw(at: CGPoint(x: rect.origin.x + 12, y: rect.origin.y + 10), withAttributes: kTitleAttr)
                    
                    let kValAttr: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 22, weight: .bold),
                        .foregroundColor: kpi.color
                    ]
                    kpi.val.draw(at: CGPoint(x: rect.origin.x + 12, y: rect.origin.y + 26), withAttributes: kValAttr)
                }
                
                // Performance Row (Completion Rate & On-Time Rate)
                let perfY: CGFloat = 200
                let perfRect = CGRect(x: 36, y: perfY, width: pageWidth - 72, height: 44)
                cgContext.setFillColor(UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0).cgColor)
                UIBezierPath(roundedRect: perfRect, cornerRadius: 8).fill()
                
                let perfAttr: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
                    .foregroundColor: UIColor.white
                ]
                let perfSummary = "Overall Completion Rate: \(stats.completionRate)%  •  On-Time Completion Rate: \(stats.onTimeRate)%  •  Academic Status: Active"
                perfSummary.draw(at: CGPoint(x: 48, y: perfY + 14), withAttributes: perfAttr)
                
                // Table Section Header
                let tableHeaderY: CGFloat = 260
                let secTitleAttr: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14, weight: .bold),
                    .foregroundColor: UIColor.white
                ]
                "ACADEMIC DEADLINE SCHEDULE".draw(at: CGPoint(x: 36, y: tableHeaderY), withAttributes: secTitleAttr)
                
                // Table Column Headers
                let rowY: CGFloat = tableHeaderY + 24
                let colH: CGFloat = 26
                let tableRect = CGRect(x: 36, y: rowY, width: pageWidth - 72, height: colH)
                cgContext.setFillColor(UIColor(red: 0.20, green: 0.20, blue: 0.20, alpha: 1.0).cgColor)
                UIBezierPath(roundedRect: tableRect, cornerRadius: 4).fill()
                
                let colAttr: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10, weight: .bold),
                    .foregroundColor: UIColor(red: 0.95, green: 0.80, blue: 0.48, alpha: 1.0)
                ]
                
                "MODULE".draw(at: CGPoint(x: 46, y: rowY + 7), withAttributes: colAttr)
                "ASSIGNMENT / MILESTONE".draw(at: CGPoint(x: 130, y: rowY + 7), withAttributes: colAttr)
                "DUE DATE".draw(at: CGPoint(x: 340, y: rowY + 7), withAttributes: colAttr)
                "PRIORITY".draw(at: CGPoint(x: 440, y: rowY + 7), withAttributes: colAttr)
                "STATUS".draw(at: CGPoint(x: 515, y: rowY + 7), withAttributes: colAttr)
                
                // Table Rows
                var currentY: CGFloat = rowY + colH + 6
                let rowHeight: CGFloat = 28
                let itemFont = UIFont.systemFont(ofSize: 10, weight: .regular)
                let itemBoldFont = UIFont.systemFont(ofSize: 10, weight: .semibold)
                
                let sortedDeadlines = deadlines.sorted { $0.dueDate < $1.dueDate }
                
                for (index, item) in sortedDeadlines.prefix(16).enumerated() {
                    let rRect = CGRect(x: 36, y: currentY, width: pageWidth - 72, height: rowHeight)
                    if index % 2 == 1 {
                        cgContext.setFillColor(UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0).cgColor)
                        UIBezierPath(roundedRect: rRect, cornerRadius: 4).fill()
                    }
                    
                    let moduleCode = item.module?.code ?? "—"
                    let moduleAttr: [NSAttributedString.Key: Any] = [.font: itemBoldFont, .foregroundColor: UIColor(red: 0.95, green: 0.80, blue: 0.48, alpha: 1.0)]
                    moduleCode.draw(at: CGPoint(x: 46, y: currentY + 7), withAttributes: moduleAttr)
                    
                    let titleStr = String(item.title.prefix(32))
                    let titleAttr: [NSAttributedString.Key: Any] = [.font: itemFont, .foregroundColor: UIColor.white]
                    titleStr.draw(at: CGPoint(x: 130, y: currentY + 7), withAttributes: titleAttr)
                    
                    let dueStr = item.formattedDueDate
                    let dueAttr: [NSAttributedString.Key: Any] = [.font: itemFont, .foregroundColor: UIColor.lightGray]
                    dueStr.draw(at: CGPoint(x: 340, y: currentY + 7), withAttributes: dueAttr)
                    
                    let priorityColor: UIColor
                    switch item.priority {
                    case .high: priorityColor = UIColor(red: 0.91, green: 0.53, blue: 0.53, alpha: 1.0)
                    case .medium: priorityColor = UIColor(red: 0.95, green: 0.80, blue: 0.48, alpha: 1.0)
                    case .low: priorityColor = UIColor(red: 0.54, green: 0.66, blue: 0.85, alpha: 1.0)
                    }
                    let prioAttr: [NSAttributedString.Key: Any] = [.font: itemBoldFont, .foregroundColor: priorityColor]
                    item.priority.rawValue.draw(at: CGPoint(x: 440, y: currentY + 7), withAttributes: prioAttr)
                    
                    let statusStr: String
                    let statusColor: UIColor
                    if item.isCompleted {
                        statusStr = "Completed"
                        statusColor = UIColor(red: 0.48, green: 0.79, blue: 0.64, alpha: 1.0)
                    } else if item.isOverdue {
                        statusStr = "Overdue"
                        statusColor = UIColor(red: 0.91, green: 0.53, blue: 0.53, alpha: 1.0)
                    } else {
                        statusStr = "Pending"
                        statusColor = UIColor(red: 0.95, green: 0.80, blue: 0.48, alpha: 1.0)
                    }
                    let statusAttr: [NSAttributedString.Key: Any] = [.font: itemBoldFont, .foregroundColor: statusColor]
                    statusStr.draw(at: CGPoint(x: 515, y: currentY + 7), withAttributes: statusAttr)
                    
                    currentY += rowHeight
                }
                
                // Footer
                let footerY: CGFloat = pageHeight - 48
                let footerAttr: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 9, weight: .regular),
                    .foregroundColor: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
                ]
                "LastMinute Academic Deadline Manager • Generated on iOS • All data stored locally on device".draw(
                    at: CGPoint(x: 36, y: footerY),
                    withAttributes: footerAttr
                )
            }
            return tempURL
        } catch {
            print("Failed to generate PDF: \(error.localizedDescription)")
            return nil
        }
    }
}
