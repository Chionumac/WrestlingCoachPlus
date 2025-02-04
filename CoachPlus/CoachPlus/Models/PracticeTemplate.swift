import Foundation

struct PracticeTemplate: Identifiable, Codable {
    var id: UUID
    let name: String
    let sections: [String]
    let intensity: Double
    
    init(id: UUID = UUID(), name: String, sections: [String], intensity: Double) {
        self.id = id
        self.name = name
        self.sections = sections
        self.intensity = intensity
    }
} 