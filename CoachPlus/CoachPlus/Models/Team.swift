import Foundation

struct Team: Identifiable, Codable {
    var id: UUID
    var name: String
    var members: [TeamMember]
    var createdDate: Date
    var isActive: Bool
    var inviteCode: String
    var ownerId: UUID
    
    init(id: UUID = UUID(), 
         name: String, 
         members: [TeamMember] = [], 
         createdDate: Date = Date(), 
         isActive: Bool = true,
         ownerId: UUID? = nil,
         inviteCode: String = "") {
        self.id = id
        self.name = name
        self.members = members
        self.createdDate = createdDate
        self.isActive = isActive
        // Generate a random invite code if none provided
        self.inviteCode = inviteCode.isEmpty ? Team.generateInviteCode() : inviteCode
        // Set the creator as owner if ownerId is nil
        self.ownerId = ownerId ?? id
    }
    
    /// Determines if a user has admin privileges for this team
    func isAdmin(_ userId: UUID) -> Bool {
        return userId == ownerId || members.contains(where: { $0.id == userId && $0.role.hasAdminPrivileges })
    }
    
    /// Generate a random 6-character alphanumeric code
    static func generateInviteCode() -> String {
        let characters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        var code = ""
        for _ in 0..<6 {
            let randomIndex = Int.random(in: 0..<characters.count)
            let character = characters[characters.index(characters.startIndex, offsetBy: randomIndex)]
            code.append(character)
        }
        return code
    }
}

struct TeamMember: Identifiable, Codable {
    var id: UUID
    var name: String
    var role: TeamRole
    var joinDate: Date
    var userId: String?  // Optional link to authentication system
    
    init(id: UUID = UUID(), name: String, role: TeamRole, joinDate: Date = Date(), userId: String? = nil) {
        self.id = id
        self.name = name
        self.role = role
        self.joinDate = joinDate
        self.userId = userId
    }
}

enum TeamRole: String, Codable, CaseIterable {
    case owner = "owner"  // Team creator with full access
    case coach = "coach"  // Can manage practices, team settings
    case assistant = "assistant"  // Can create/edit practices
    case athlete = "athlete"  // Can view assigned practices
    case parent = "parent"  // Can view athlete's schedule
    case manager = "manager"  // Can handle logistics but not practices
    
    var description: String {
        switch self {
        case .owner:
            return "Team Owner"
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
    
    var hasAdminPrivileges: Bool {
        switch self {
        case .owner, .coach:
            return true
        default:
            return false
        }
    }
    
    var canEditPractices: Bool {
        switch self {
        case .owner, .coach, .assistant:
            return true
        default:
            return false
        }
    }
    
    var canViewTeamSettings: Bool {
        switch self {
        case .owner, .coach, .manager:
            return true
        default:
            return false
        }
    }
} 