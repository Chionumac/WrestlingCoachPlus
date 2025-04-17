import Foundation

struct Team: Identifiable, Codable {
    var id: UUID
    var name: String
    var members: [TeamMember]
    var createdDate: Date
    var isActive: Bool
    
    init(id: UUID = UUID(), name: String, members: [TeamMember] = [], createdDate: Date = Date(), isActive: Bool = true) {
        self.id = id
        self.name = name
        self.members = members
        self.createdDate = createdDate
        self.isActive = isActive
    }
}

struct TeamMember: Identifiable, Codable {
    var id: UUID
    var name: String
    var role: TeamRole
    
    init(id: UUID = UUID(), name: String, role: TeamRole) {
        self.id = id
        self.name = name
        self.role = role
    }
}

enum TeamRole: String, Codable, CaseIterable {
    case coach
    case assistant
    case athlete
    case manager
    case parent
    
    var description: String {
        switch self {
        case .coach:
            return "Head Coach"
        case .assistant:
            return "Assistant Coach"
        case .athlete:
            return "Athlete"
        case .manager:
            return "Team Manager"
        case .parent:
            return "Parent/Guardian"
        }
    }
} 