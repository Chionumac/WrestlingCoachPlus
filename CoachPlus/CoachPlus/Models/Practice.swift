import Foundation

struct Practice: Identifiable, Codable {
    let id: UUID
    let date: Date
    let type: PracticeType
    let sections: [String]
    let intensity: Double
    let isFromTemplate: Bool
    let includesLift: Bool
    let liveTimeMinutes: Int
    
    init(
        id: UUID = UUID(),
        date: Date,
        type: PracticeType,
        sections: [String],
        intensity: Double,
        isFromTemplate: Bool,
        includesLift: Bool = false,
        liveTimeMinutes: Int = 0
    ) {
        self.id = id
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: date)
        self.date = calendar.date(from: DateComponents(
            year: dateComponents.year,
            month: dateComponents.month,
            day: dateComponents.day,
            hour: timeComponents.hour,
            minute: timeComponents.minute
        )) ?? date
        self.type = type
        self.sections = sections.isEmpty ? type.defaultSections : sections
        self.intensity = intensity
        self.isFromTemplate = isFromTemplate
        self.includesLift = includesLift
        self.liveTimeMinutes = liveTimeMinutes
    }
}

extension PracticeType {
    var defaultSections: [String] {
        switch self {
        case .rest:
            return ["Rest Day"]
        case .practice, .competition:
            return [""]
        }
    }
} 