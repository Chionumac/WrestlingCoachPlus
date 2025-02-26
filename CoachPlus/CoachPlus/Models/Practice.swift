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
    
    // MARK: - Validation
    var isValid: Bool {
        !sections.isEmpty && sections.first?.isEmpty == false
    }
    
    var hasContent: Bool {
        sections.count > 1 || (sections.first?.isEmpty == false)
    }
    
    // MARK: - Computed Properties
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // MARK: - Display Properties
    var displayTitle: String {
        switch type {
        case .practice:
            return sections.first ?? "Practice"
        case .competition:
            return sections.first?.replacingOccurrences(of: "Competition: ", with: "") ?? "Competition"
        case .rest:
            return "Rest Day"
        }
    }
    
    var displaySummary: String {
        switch type {
        case .competition:
            // Get competition details
            let details = sections.dropFirst().joined(separator: "\n")
            return details.isEmpty ? "No details" : details
        case .practice:
            // Get practice blocks
            return sections.dropFirst().joined(separator: "\n")
        case .rest:
            return "Rest Day"
        }
    }
    
    var displayIntensity: String {
        if type == .rest { return "" }
        return "\(Int(intensity * 100))%"
    }
    
    var displayDetails: String {
        var details: [String] = []
        if liveTimeMinutes > 0 {
            details.append("\(liveTimeMinutes)min live")
        }
        if includesLift {
            details.append("Lift")
        }
        return details.joined(separator: " • ")
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