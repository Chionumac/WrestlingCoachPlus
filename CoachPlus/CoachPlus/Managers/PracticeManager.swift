import Foundation

class PracticeManager {
    // MARK: - Properties
    private let practicesKey = "savedPractices"
    private var practices: [Practice] = []
    
    // MARK: - Init
    init() {
        practices = loadPractices()
    }
    
    // MARK: - Public Methods
    func getPractices() -> [Practice] {
        practices
    }
    
    func savePractice(_ practice: Practice) {
        // Remove any existing practice for this date
        practices.removeAll { Calendar.current.isDate($0.date, inSameDayAs: practice.date) }
        
        // Add the new practice
        practices.append(practice)
        
        // Save to storage
        savePractices(practices)
    }
    
    func deletePractice(for date: Date) {
        practices.removeAll { Calendar.current.isDate($0.date, inSameDayAs: date) }
        savePractices(practices)
    }
    
    // MARK: - Private Methods
    private func loadPractices() -> [Practice] {
        if let data = UserDefaults.standard.data(forKey: practicesKey),
           let decoded = try? JSONDecoder().decode([Practice].self, from: data) {
            return decoded
        }
        return []
    }
    
    private func savePractices(_ practices: [Practice]) {
        if let encoded = try? JSONEncoder().encode(practices) {
            UserDefaults.standard.set(encoded, forKey: practicesKey)
        }
    }
}

extension PracticeManager {
    func combineDateAndTime(date: Date, time: Date) -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        return calendar.date(from: DateComponents(
            year: dateComponents.year,
            month: dateComponents.month,
            day: dateComponents.day,
            hour: timeComponents.hour,
            minute: timeComponents.minute
        )) ?? date
    }
    
    func practiceForDate(_ date: Date) -> Practice? {
        practices.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    // Add practice creation methods
    @discardableResult
    func createPractice(
        date: Date,
        time: Date,
        type: PracticeType,
        sections: [String],
        intensity: Double,
        isFromTemplate: Bool = false,
        includesLift: Bool = false,
        liveTimeMinutes: Int = 0
    ) throws -> Practice {
        // Validate inputs
        guard !sections.isEmpty else {
            throw PracticeError.invalidSections
        }
        
        let combinedDate = combineDateAndTime(date: date, time: time)
        
        let practice = Practice(
            date: combinedDate,
            type: type,
            sections: sections,
            intensity: intensity,
            isFromTemplate: isFromTemplate,
            includesLift: includesLift,
            liveTimeMinutes: liveTimeMinutes
        )
        
        savePractice(practice)
        return practice
    }
    
    func createRecurringPractices(
        startDate: Date,
        endDate: Date,
        pattern: RecurrencePattern,
        time: Date,
        type: PracticeType,
        sections: [String],
        intensity: Double,
        includesLift: Bool,
        liveTimeMinutes: Int
    ) throws {
        var currentDate = startDate
        while let nextDate = pattern.nextDate(from: currentDate),
              nextDate <= endDate {
            try createPractice(
                date: nextDate,
                time: time,
                type: type,
                sections: sections,
                intensity: intensity,
                includesLift: includesLift,
                liveTimeMinutes: liveTimeMinutes
            )
            currentDate = nextDate
        }
    }
} 