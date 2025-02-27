import Foundation

class PracticeManager {
    // MARK: - Properties
    private let service: PracticeServiceProtocol
    
    // MARK: - Init
    init(service: PracticeServiceProtocol = UserDefaultsPracticeService()) {
        self.service = service
    }
    
    // MARK: - Public Methods
    func getPractices() -> [Practice] {
        service.load()
    }
    
    func savePractice(_ practice: Practice) {
        try? service.save(practice)
    }
    
    func deletePractice(for date: Date) {
        service.delete(for: date)
    }
    
    func practiceForDate(_ date: Date) -> Practice? {
        service.getPractice(for: date)
    }
    
    // Helper method
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
    
    // MARK: - Practice Creation Methods
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
        
        try service.save(practice)
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
        var practices: [Practice] = []
        var currentDate = startDate
        
        while let nextDate = pattern.nextDate(from: currentDate),
              nextDate <= endDate {
            let practice = try createPractice(
                date: nextDate,
                time: time,
                type: type,
                sections: sections,
                intensity: intensity,
                includesLift: includesLift,
                liveTimeMinutes: liveTimeMinutes
            )
            practices.append(practice)
            currentDate = nextDate
        }
        
        try service.saveMultiple(practices)
    }
} 