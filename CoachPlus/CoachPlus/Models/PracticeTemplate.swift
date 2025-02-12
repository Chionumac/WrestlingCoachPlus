import Foundation

struct PracticeTemplate: Identifiable, Codable {
    var id: UUID
    let name: String
    let sections: [String]
    let intensity: Double
    let liveTimeMinutes: Int
    let includesLift: Bool
    let practiceTime: Date
    
    init(id: UUID = UUID(), name: String, sections: [String], intensity: Double, liveTimeMinutes: Int, includesLift: Bool, practiceTime: Date) {
        self.id = id
        self.name = name
        self.sections = sections
        self.intensity = intensity
        self.liveTimeMinutes = liveTimeMinutes
        self.includesLift = includesLift
        self.practiceTime = practiceTime
    }
} 