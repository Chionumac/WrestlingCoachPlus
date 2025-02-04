import SwiftUI

struct CalendarView: View {
    @Binding var selectedDate: Date
    @Binding var showingAddPractice: Bool
    @Binding var showingPracticeDetails: Bool
    let practices: [Practice]
    private let calendar = Calendar.current
    private let daysInWeek = 7
    
    // Number of months to show before and after the current month
    private let monthsToShow = 12
    
    var body: some View {
        GeometryReader { geometry in
            let leftInset: CGFloat = 8
            let rightInset: CGFloat = 50
            let availableWidth = geometry.size.width - (leftInset + rightInset)
            let cellWidth = availableWidth / CGFloat(daysInWeek)
            
            TabView(selection: monthBinding) {
                ForEach(-monthsToShow...monthsToShow, id: \.self) { monthOffset in
                    MonthView(
                        monthOffset: monthOffset,
                        selectedDate: $selectedDate,
                        showingAddPractice: $showingAddPractice,
                        showingPracticeDetails: $showingPracticeDetails,
                        practices: practices,
                        leftInset: leftInset,
                        rightInset: rightInset,
                        cellWidth: cellWidth
                    )
                    .tag(monthOffset)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
    
    private var monthBinding: Binding<Int> {
        Binding(
            get: {
                let components = calendar.dateComponents([.month], from: calendar.startOfMonth(for: Date()), to: calendar.startOfMonth(for: selectedDate))
                return components.month ?? 0
            },
            set: { newOffset in
                if let newDate = calendar.date(byAdding: .month, value: newOffset, to: calendar.startOfMonth(for: Date())) {
                    selectedDate = newDate
                }
            }
        )
    }
}

struct MonthView: View {
    let monthOffset: Int
    @Binding var selectedDate: Date
    @Binding var showingAddPractice: Bool
    @Binding var showingPracticeDetails: Bool
    let practices: [Practice]
    let leftInset: CGFloat
    let rightInset: CGFloat
    let cellWidth: CGFloat
    
    private let calendar = Calendar.current
    private let daysInWeek = 7
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 10) {
                // Month and Year header
                HStack {
                    Text(currentMonth.formatted(.dateTime.month(.wide).year()))
                        .font(.title.bold())
                    Spacer()
                }
                .padding(.leading, leftInset)
                .padding(.trailing, rightInset)
                
                // Days of week header with black line
                VStack(spacing: 0) {
                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(cellWidth)), count: daysInWeek), spacing: 0) {
                        ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                            Text(day.prefix(1)) // Take first letter of each day
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: geometry.size.width - (leftInset + rightInset))
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(.black)
                        .padding(.top, 1)
                }
                
                // Calendar grid with week separators
                VStack(spacing: 0) {
                    let weeks = createWeeks(from: daysInMonth())
                    ForEach(0..<weeks.count, id: \.self) { weekIndex in
                        VStack(spacing: 0) {
                            // Week row
                            LazyVGrid(columns: Array(repeating: GridItem(.fixed(cellWidth)), count: daysInWeek), spacing: 0) {
                                ForEach(weeks[weekIndex], id: \.self) { calendarDay in
                                    if let date = calendarDay.date {
                                        DayCell(
                                            date: date,
                                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                            practice: practices.first { calendar.isDate($0.date, inSameDayAs: date) },
                                            cellSize: cellWidth
                                        )
                                        .onTapGesture {
                                            selectedDate = date
                                        }
                                        .onTapGesture(count: 2) {
                                            selectedDate = date
                                            if practices.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) != nil {
                                                showingPracticeDetails = true
                                            } else {
                                                showingAddPractice = true
                                            }
                                        }
                                    } else {
                                        Color.clear
                                            .frame(width: cellWidth, height: cellWidth)
                                    }
                                }
                            }
                            
                            // Week separator line (except after last week)
                            if weekIndex < weeks.count - 1 {
                                Rectangle()
                                    .frame(height: 0.5)
                                    .foregroundStyle(.gray.opacity(0.3))
                                    .padding(.vertical, 4)
                            }
                        }
                    }
                    
                    // Bottom calendar line
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundStyle(.gray.opacity(0.3))
                        .padding(.top, 4)
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.vertical, 8)
            .padding(.leading, leftInset)
            .padding(.trailing, rightInset)
        }
    }
    
    private var currentMonth: Date {
        calendar.date(byAdding: .month, value: monthOffset, to: calendar.startOfMonth(for: Date()))!
    }
    
    private func daysInMonth() -> [CalendarDay] {
        let interval = calendar.dateInterval(of: .month, for: currentMonth)!
        let firstDayOfMonth = interval.start
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let offsetFromSunday = firstWeekday - 1
        
        let lastDayOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDayOfMonth)!
        let lastWeekday = calendar.component(.weekday, from: lastDayOfMonth)
        let daysToSaturday = 7 - lastWeekday
        
        var days: [CalendarDay] = []
        
        // Add padding days at start
        for _ in 0..<offsetFromSunday {
            days.append(CalendarDay(date: nil, isWithinMonth: false))
        }
        
        // Add days of month
        let numberOfDays = calendar.component(.day, from: lastDayOfMonth)
        for dayOffset in 0..<numberOfDays {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: firstDayOfMonth)!
            days.append(CalendarDay(date: date, isWithinMonth: true))
        }
        
        // Add padding days at end
        for _ in 0..<daysToSaturday {
            days.append(CalendarDay(date: nil, isWithinMonth: false))
        }
        
        return days
    }
    
    // Helper function to organize days into weeks
    private func createWeeks(from days: [CalendarDay]) -> [[CalendarDay]] {
        var weeks: [[CalendarDay]] = []
        var currentWeek: [CalendarDay] = []
        
        for day in days {
            currentWeek.append(day)
            if currentWeek.count == 7 {
                weeks.append(currentWeek)
                currentWeek = []
            }
        }
        
        if !currentWeek.isEmpty {
            weeks.append(currentWeek)
        }
        
        return weeks
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let practice: Practice?
    let cellSize: CGFloat
    private let calendar = Calendar.current
    
    private var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(calendar.component(.day, from: date))")
                .font(.title3)
                .foregroundStyle(textColor)
            
            if let practice = practice {
                if practice.type == .competition {
                    Image(systemName: "trophy.fill")
                        .font(.caption2)
                        .foregroundStyle(.black)
                }
                if practice.includesLift {
                    Image(systemName: "dumbbell.fill")
                        .font(.caption2)
                        .foregroundStyle(.black)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: cellSize * 0.9)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(cellBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(isToday ? .blue : .clear, lineWidth: 2)
        )
    }
    
    private var cellBackground: Color {
        if let practice = practice {
            switch practice.type {
            case .competition:
                let hue = max(0, min(0.3, 0.3 * practice.intensity))  // Clamp between 0 and 0.3
                return Color(
                    hue: hue,
                    saturation: 0.8,
                    brightness: 0.9
                ).opacity(isSelected ? 0.9 : 0.7)
            case .rest:
                return Color(.systemGray4).opacity(isSelected ? 0.4 : 0.3)
            default:
                let hue = max(0, min(0.3, 0.3 - (practice.intensity * 0.3)))  // Clamp between 0 and 0.3
                return Color(
                    hue: hue,
                    saturation: 0.8,
                    brightness: 0.9
                ).opacity(isSelected ? 0.9 : 0.7)
            }
        }
        if isSelected {
            return .blue.opacity(0.4)
        }
        return .clear
    }
    
    private var textColor: Color {
        if let practice = practice {
            switch practice.type {
            case .competition:
                return isSelected ? .white : .primary
            case .rest:
                return isSelected ? .primary : .secondary // Kept text color consistent
            default:
                return isSelected ? .white : .primary
            }
        }
        return .primary
    }
}

// Add Calendar extension for convenience
extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components)!
    }
}

// Add this struct at the top of the file
struct CalendarDay: Identifiable, Hashable {
    let id: String
    let date: Date?
    let isWithinMonth: Bool
    
    init(date: Date?, isWithinMonth: Bool) {
        if let date = date {
            // Use date components for ID when we have a date
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            self.id = "\(components.year ?? 0)-\(components.month ?? 0)-\(components.day ?? 0)"
        } else {
            // Use UUID for empty days
            self.id = UUID().uuidString
        }
        self.date = date
        self.isWithinMonth = isWithinMonth
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: CalendarDay, rhs: CalendarDay) -> Bool {
        lhs.id == rhs.id
    }
}

#Preview {
    CalendarView(selectedDate: .constant(Date()), showingAddPractice: .constant(false), showingPracticeDetails: .constant(false), practices: [])
        .frame(height: 400)
} 
