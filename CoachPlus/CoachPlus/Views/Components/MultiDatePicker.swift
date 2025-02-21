import SwiftUI

struct MultiDatePicker: View {
    @Binding var selectedDates: Set<Date>
    @Environment(\.calendar) private var calendar
    private let gridColumns = Array(repeating: GridItem(.flexible()), count: 7)
    
    @State private var displayedMonth = Date()
    
    var body: some View {
        VStack(spacing: 20) {
            // Month selector
            HStack {
                Button(action: { moveMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                }
                
                Spacer()
                
                Text(displayedMonth.formatted(.dateTime.month().year()))
                    .font(.title3.bold())
                
                Spacer()
                
                Button(action: { moveMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .imageScale(.large)
                }
            }
            .padding(.horizontal)
            
            // Weekday headers
            LazyVGrid(columns: gridColumns) {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                    Text(day.prefix(1))
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: gridColumns, spacing: 8) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        DayButton(
                            date: date,
                            isSelected: selectedDates.contains { 
                                calendar.isDate($0, inSameDayAs: date)
                            }
                        ) {
                            toggleDate(date)
                        }
                    } else {
                        Color.clear
                            .aspectRatio(1, contentMode: .fill)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func moveMonth(by value: Int) {
        if let newDate = calendar.date(
            byAdding: .month,
            value: value,
            to: displayedMonth
        ) {
            displayedMonth = newDate
        }
    }
    
    private func toggleDate(_ date: Date) {
        if selectedDates.contains(where: { calendar.isDate($0, inSameDayAs: date) }) {
            selectedDates.remove(date)
        } else {
            selectedDates.insert(date)
        }
    }
    
    private func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth) else {
            return []
        }
        
        let firstDayOfMonth = monthInterval.start
        let lastDayOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDayOfMonth)!
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let offsetFromSunday = firstWeekday - 1
        
        let lastWeekday = calendar.component(.weekday, from: lastDayOfMonth)
        let daysToSaturday = 7 - lastWeekday
        
        var days: [Date?] = []
        
        // Add empty days at start
        for _ in 0..<offsetFromSunday {
            days.append(nil)
        }
        
        // Add all days in month
        let numberOfDays = calendar.component(.day, from: lastDayOfMonth)
        for dayOffset in 0..<numberOfDays {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        // Add empty days at end
        for _ in 0..<daysToSaturday {
            days.append(nil)
        }
        
        return days
    }
}

struct DayButton: View {
    let date: Date
    let isSelected: Bool
    let action: () -> Void
    
    @Environment(\.calendar) private var calendar
    
    private var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    var body: some View {
        Button(action: action) {
            Text("\(calendar.component(.day, from: date))")
                .font(.callout)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundStyle(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fill)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? .blue : .clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(isToday ? .blue : .clear, lineWidth: 1)
                )
        }
    }
} 