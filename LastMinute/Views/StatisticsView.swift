//
//  StatisticsView.swift
//  LastMinute
//

import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Query private var deadlines: [Deadline]
    
    @State private var pdfURLToShare: URL? = nil
    @State private var showShareSheet: Bool = false
    @State private var selectedSemester: String = "Spring '26"
    
    private var stats: SemesterStats {
        StatisticsCalculator.calculate(deadlines: deadlines)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                StitchTheme.canvasBase.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Top Header
                        HStack(alignment: .center) {
                            HStack(spacing: 10) {
                                Image("AppLogo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 32, height: 32)
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("LASTMINUTE")
                                        .font(.system(size: 10, weight: .bold))
                                        .tracking(1.0)
                                        .foregroundColor(StitchTheme.primaryGold)
                                    
                                    Text("Statistics")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(StitchTheme.textPrimary)
                                }
                            }
                            
                            Spacer()
                            
                            Image("UserAvatar")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 36, height: 36)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(StitchTheme.primaryGold.opacity(0.4), lineWidth: 1.5))
                        }
                        .padding(.top, 4)
                        
                        // Title & Subtitle + Semester Dropdown
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Your Progress")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(StitchTheme.textPrimary)
                                
                                Text("See how you're keeping up this semester.")
                                    .font(.system(size: 14))
                                    .foregroundColor(StitchTheme.textSecondary)
                            }
                            
                            Spacer()
                            
                            Menu {
                                Button("Spring '26") { selectedSemester = "Spring '26" }
                                Button("Fall '25") { selectedSemester = "Fall '25" }
                                Button("All Time") { selectedSemester = "All Time" }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(selectedSemester)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(StitchTheme.textPrimary)
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(StitchTheme.primaryGold)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(StitchTheme.cardElevated)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(StitchTheme.borderSubtle, lineWidth: 1))
                            }
                        }
                        
                        // Hero Circular Completion Ring Card
                        ProgressRing(
                            percentage: stats.completionRate,
                            completedCount: stats.completedCount,
                            totalCount: stats.totalCount
                        )
                        
                        // 2x2 Metric Grid Cards
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            // Completed Card
                            MetricCard(
                                title: "COMPLETED",
                                icon: "checkmark.circle.fill",
                                iconColor: StitchTheme.successMint,
                                value: String(format: "%02d", stats.completedCount),
                                valueColor: StitchTheme.successMint,
                                subtitle: "↑ +3 wk",
                                subtitleColor: StitchTheme.successMint
                            )
                            
                            // Pending Card
                            MetricCard(
                                title: "PENDING",
                                icon: "clock.fill",
                                iconColor: StitchTheme.primaryGold,
                                value: String(format: "%02d", stats.pendingCount),
                                valueColor: StitchTheme.primaryGold,
                                subtitle: "In Queue",
                                subtitleColor: StitchTheme.textSecondary
                            )
                            
                            // Overdue Card
                            MetricCard(
                                title: "OVERDUE",
                                icon: "exclamationmark.triangle.fill",
                                iconColor: StitchTheme.criticalCoral,
                                value: String(format: "%02d", stats.overdueCount),
                                valueColor: stats.overdueCount > 0 ? StitchTheme.criticalCoral : StitchTheme.textPrimary,
                                subtitle: stats.overdueCount > 0 ? "Needs Action" : "Clear",
                                subtitleColor: stats.overdueCount > 0 ? StitchTheme.criticalCoral : StitchTheme.textSecondary
                            )
                            
                            // On-Time Card
                            MetricCard(
                                title: "ON-TIME",
                                icon: "bolt.fill",
                                iconColor: StitchTheme.primaryGold,
                                value: "\(stats.onTimeRate)%",
                                valueColor: StitchTheme.textPrimary,
                                subtitle: "Elite",
                                subtitleBadgeColor: StitchTheme.successMint
                            )
                        }
                        
                        // Weekly Activity Card using Swift Charts
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Weekly Activity")
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundColor(StitchTheme.textPrimary)
                                    Text("Deadlines resolved by day")
                                        .font(.system(size: 12))
                                        .foregroundColor(StitchTheme.textSecondary)
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(StitchTheme.primaryGold)
                                        .frame(width: 6, height: 6)
                                    Text("THIS WEEK")
                                        .font(.system(size: 10, weight: .bold))
                                        .tracking(0.6)
                                        .foregroundColor(StitchTheme.primaryGold)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(StitchTheme.canvasSecondary)
                                .clipShape(Capsule())
                            }
                            
                            // Swift Chart
                            Chart {
                                ForEach(stats.weeklyActivity) { item in
                                    BarMark(
                                        x: .value("Day", item.dayName),
                                        y: .value("Completed", item.count)
                                    )
                                    .foregroundStyle(
                                        item.isCurrentDay ? StitchTheme.primaryGold : StitchTheme.cardHighlight
                                    )
                                    .cornerRadius(6)
                                    .annotation(position: .top) {
                                        if item.isCurrentDay && item.count > 0 {
                                            Text("\(item.count) Done")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(StitchTheme.canvasBase)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(StitchTheme.primaryGold)
                                                .clipShape(Capsule())
                                                .offset(y: -4)
                                        }
                                    }
                                }
                            }
                            .frame(height: 150)
                            .chartYAxis {
                                AxisMarks(position: .leading) { _ in
                                    AxisGridLine().foregroundStyle(StitchTheme.borderSubtle.opacity(0.4))
                                    AxisValueLabel().foregroundStyle(StitchTheme.textMuted)
                                }
                            }
                            .chartXAxis {
                                AxisMarks { value in
                                    AxisValueLabel().foregroundStyle(StitchTheme.textSecondary)
                                }
                            }
                        }
                        .padding(16)
                        .stitchCard(cornerRadius: 20, background: StitchTheme.cardSurface)
                        
                        // Deadlines by Priority Section
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Deadlines by Priority")
                                        .font(.system(size: 17, weight: .bold))
                                        .foregroundColor(StitchTheme.textPrimary)
                                    Text("Focus volume and resolution")
                                        .font(.system(size: 12))
                                        .foregroundColor(StitchTheme.textSecondary)
                                }
                                
                                Spacer()
                                
                                Text("\(stats.totalCount) Total")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(StitchTheme.textSecondary)
                            }
                            
                            VStack(spacing: 12) {
                                PriorityProgressBarRow(
                                    label: "High Priority",
                                    dotColor: StitchTheme.criticalCoral,
                                    barColor: StitchTheme.criticalCoral,
                                    count: stats.highPriorityCount,
                                    total: max(1, stats.totalCount)
                                )
                                
                                PriorityProgressBarRow(
                                    label: "Medium Priority",
                                    dotColor: StitchTheme.primaryGold,
                                    barColor: StitchTheme.primaryGold,
                                    count: stats.mediumPriorityCount,
                                    total: max(1, stats.totalCount)
                                )
                                
                                PriorityProgressBarRow(
                                    label: "Low Priority",
                                    dotColor: StitchTheme.infoBlue,
                                    barColor: StitchTheme.infoBlue,
                                    count: stats.lowPriorityCount,
                                    total: max(1, stats.totalCount)
                                )
                            }
                        }
                        .padding(16)
                        .stitchCard(cornerRadius: 20, background: StitchTheme.cardSurface)
                        
                        // Achievement Card
                        HStack(alignment: .top, spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color(hex: "#694B00").opacity(0.8))
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(StitchTheme.primaryGold)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("ACHIEVEMENT UNLOCKED")
                                        .font(.system(size: 10, weight: .bold))
                                        .tracking(0.6)
                                        .foregroundColor(StitchTheme.primaryGold)
                                    
                                    Spacer()
                                    
                                    Text(stats.achievementBadge)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(StitchTheme.canvasBase)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(StitchTheme.primaryGold)
                                        .clipShape(Capsule())
                                }
                                
                                Text(stats.achievementText)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(StitchTheme.textPrimary)
                                    .lineSpacing(2)
                            }
                        }
                        .padding(14)
                        .stitchCard(cornerRadius: 18, background: StitchTheme.cardElevated)
                        
                        // Export Summary Button
                        Button(action: {
                            exportSemesterSummary()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.down.doc")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(StitchTheme.primaryGold)
                                
                                Text("Export Semester Summary")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(StitchTheme.textPrimary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(StitchTheme.cardSurface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(StitchTheme.borderSubtle, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 4)
                        
                        Spacer(minLength: 80)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = pdfURLToShare {
                    ShareSheetView(activityItems: [url])
                }
            }
        }
    }
    
    private func exportSemesterSummary() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        if let pdfURL = PDFExportService.shared.generateSemesterSummaryPDF(deadlines: deadlines, stats: stats) {
            self.pdfURLToShare = pdfURL
            self.showShareSheet = true
        }
    }
}

// 2x2 Metric Card Component
struct MetricCard: View {
    let title: String
    let icon: String
    let iconColor: Color
    let value: String
    var valueColor: Color = StitchTheme.textPrimary
    var subtitle: String = ""
    var subtitleColor: Color = StitchTheme.textSecondary
    var subtitleBadgeColor: Color? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.6)
                    .foregroundColor(StitchTheme.textSecondary)
                
                Spacer()
                
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(iconColor)
            }
            
            HStack(alignment: .firstTextBaseline) {
                Text(value)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(valueColor)
                
                Spacer()
                
                if let badge = subtitleBadgeColor {
                    Text(subtitle)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(StitchTheme.canvasBase)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(badge)
                        .clipShape(Capsule())
                } else {
                    Text(subtitle)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(subtitleColor)
                }
            }
        }
        .padding(14)
        .stitchCard(cornerRadius: 18, background: StitchTheme.cardSurface)
    }
}

// Priority Progress Bar Row
struct PriorityProgressBarRow: View {
    let label: String
    let dotColor: Color
    let barColor: Color
    let count: Int
    let total: Int
    
    var fraction: Double {
        total > 0 ? Double(count) / Double(total) : 0
    }
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(dotColor)
                        .frame(width: 6, height: 6)
                    Text(label)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(StitchTheme.textPrimary)
                }
                
                Spacer()
                
                Text("\(count) deadlines")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(StitchTheme.textSecondary)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(StitchTheme.cardHighlight)
                        .frame(height: 6)
                    
                    Capsule()
                        .fill(barColor)
                        .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(fraction))), height: 6)
                }
            }
            .frame(height: 6)
        }
    }
}

// Native UIKit Share Sheet
struct ShareSheetView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
