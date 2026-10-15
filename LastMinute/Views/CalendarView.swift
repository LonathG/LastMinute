//
//  CalendarView.swift
//  LastMinute
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Deadline.dueDate) private var deadlines: [Deadline]
    
    @Binding var hideTabBar: Bool
    
    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date = Date()
    @State private var showCreateDeadline: Bool = false
    @State private var selectedDeadlineForDetails: Deadline? = nil
    @State private var filterOnlyPending: Bool = false
    
    private let calendar = Calendar.current
    private let weekDaySymbols = ["S", "M", "T", "W", "T", "F", "S"]
    
    // Deadlines scheduled on the selected date
    private var deadlinesForSelectedDate: [Deadline] {
        let matching = deadlines.filter {
            calendar.isDate($0.dueDate, inSameDayAs: selectedDate)
        }
        if filterOnlyPending {
            return matching.filter { !$0.isCompleted }
        }
        return matching
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                StitchTheme.canvasBase.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        // Top Header: Branding
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
                                    
                                    Text("Calendar")
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
                        
                        // Month Navigation Bar
                        HStack(spacing: 12) {
                            // Prev Month Button
                            Button(action: {
                                changeMonth(by: -1)
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(StitchTheme.textPrimary)
                                    .frame(width: 38, height: 38)
                                    .background(StitchTheme.cardElevated)
                                    .clipShape(Circle())
                            }
                            
                            // Month Title
                            Text(DateUtilities.monthYearString(from: currentMonth))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(StitchTheme.textPrimary)
                            
                            // Next Month Button
                            Button(action: {
                                changeMonth(by: 1)
                            }) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(StitchTheme.textPrimary)
                                    .frame(width: 38, height: 38)
                                    .background(StitchTheme.cardElevated)
                                    .clipShape(Circle())
                            }
                            
                            Spacer()
                            
                            // TODAY Button
                            Button(action: {
                                withAnimation(.spring) {
                                    currentMonth = Date()
                                    selectedDate = Date()
                                }
                            }) {
                                Text("TODAY")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(0.6)
                                    .foregroundColor(StitchTheme.canvasBase)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(StitchTheme.primaryGold)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                        
                        // Calendar Grid Card
                        VStack(spacing: 12) {
                            // Days of week header
                            HStack {
                                ForEach(weekDaySymbols, id: \.self) { symbol in
                                    Text(symbol)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(StitchTheme.textMuted)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.bottom, 4)
                            
                            // Days grid
                            let days = DateUtilities.generateDaysInMonth(for: currentMonth)
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                                ForEach(days) { day in
                                    let isSelected = calendar.isDate(day.date, inSameDayAs: selectedDate)
                                    let dayDeadlines = deadlines.filter { calendar.isDate($0.dueDate, inSameDayAs: day.date) }
                                    
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedDate = day.date
                                        }
                                    }) {
                                        VStack(spacing: 4) {
                                            ZStack {
                                                if isSelected {
                                                    Circle()
                                                        .fill(StitchTheme.primaryGold)
                                                        .frame(width: 36, height: 36)
                                                        .gildedGlow(radius: 8, opacity: 0.4)
                                                } else if day.isToday {
                                                    Circle()
                                                        .stroke(StitchTheme.borderSubtle, lineWidth: 1.5)
                                                        .frame(width: 36, height: 36)
                                                }
                                                
                                                Text(DateUtilities.dayNumberString(from: day.date))
                                                    .font(.system(size: 15, weight: isSelected || day.isToday ? .bold : .medium))
                                                    .foregroundColor(
                                                        isSelected ? StitchTheme.canvasBase :
                                                        (day.isCurrentMonth ? StitchTheme.textPrimary : StitchTheme.textMuted.opacity(0.4))
                                                    )
                                            }
                                            
                                            // Deadline dots indicator
                                            HStack(spacing: 2) {
                                                ForEach(dayDeadlines.prefix(3)) { d in
                                                    Circle()
                                                        .fill(isSelected ? StitchTheme.canvasBase : (d.isOverdue ? StitchTheme.criticalCoral : (d.module?.color ?? StitchTheme.primaryGold)))
                                                        .frame(width: 4, height: 4)
                                                }
                                            }
                                            .frame(height: 5)
                                        }
                                        .frame(height: 48)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(16)
                        .stitchCard(cornerRadius: 22, background: StitchTheme.cardSurface)
                        
                        // Deadlines for Selected Date Section Header
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Deadlines for \(DateUtilities.fullDateString(from: selectedDate))")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(StitchTheme.textPrimary)
                                    
                                    Text("\(deadlinesForSelectedDate.count) assignments due")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(StitchTheme.primaryGold)
                                }
                                
                                Spacer()
                                
                                // Filter Toggle Button
                                Button(action: {
                                    filterOnlyPending.toggle()
                                }) {
                                    Image(systemName: filterOnlyPending ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                                        .font(.system(size: 20))
                                        .foregroundColor(filterOnlyPending ? StitchTheme.primaryGold : StitchTheme.textSecondary)
                                        .frame(width: 36, height: 36)
                                        .background(StitchTheme.cardElevated)
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, 4)
                        
                        // Deadlines list for date
                        if deadlinesForSelectedDate.isEmpty {
                            VStack(spacing: 8) {
                                Text("No deadlines due on this day.")
                                    .font(.system(size: 14))
                                    .foregroundColor(StitchTheme.textMuted)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                            .stitchCard(cornerRadius: 18, background: StitchTheme.cardSurface)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(deadlinesForSelectedDate) { item in
                                    DeadlineCalendarItemCard(deadline: item) {
                                        selectedDeadlineForDetails = item
                                    }
                                }
                            }
                        }
                        
                        // Bottom Add Deadline for chosen date button
                        Button(action: {
                            showCreateDeadline = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(StitchTheme.primaryGold)
                                
                                Text("Add Deadline for \(selectedDate.formatted(.dateTime.month(.abbreviated).day()))")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(StitchTheme.primaryGold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(StitchTheme.cardSurface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(StitchTheme.primaryGold.opacity(0.3), lineWidth: 1)
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
            .sheet(isPresented: $showCreateDeadline) {
                CreateDeadlineView(initialDate: selectedDate)
            }
            .navigationDestination(item: $selectedDeadlineForDetails) { item in
                DeadlineDetailView(deadline: item)
            }
            .onChange(of: selectedDeadlineForDetails) { _, newValue in
                hideTabBar = (newValue != nil)
            }
        }
    }
    
    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            withAnimation(.spring) {
                currentMonth = newMonth
            }
        }
    }
}

// Special Deadline Card for Calendar Screen matching Stitch Layout
struct DeadlineCalendarItemCard: View {
    let deadline: Deadline
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(deadline.title)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(deadline.isCompleted ? StitchTheme.textSecondary : StitchTheme.textPrimary)
                            .lineLimit(1)
                        
                        Text(deadline.module?.displayChipTitle ?? "Academic Milestone")
                            .font(.system(size: 12))
                            .foregroundColor(StitchTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    PriorityBadge(priority: deadline.priority)
                }
                
                HStack {
                    HStack(spacing: 5) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                            .foregroundColor(StitchTheme.primaryGold)
                        
                        Text(DateUtilities.timeString(from: deadline.dueDate))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(StitchTheme.primaryGold)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text(deadline.formattedRemainingShort)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(StitchTheme.textSecondary)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(StitchTheme.textMuted)
                    }
                }
            }
            .padding(14)
            .stitchCard(isUrgent: deadline.isNextUrgent, cornerRadius: 16, background: StitchTheme.cardElevated)
        }
        .buttonStyle(.plain)
    }
}
