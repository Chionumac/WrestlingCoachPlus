import Foundation

enum PracticeType: String, Codable, CaseIterable, Equatable {
    case practice = "practice"
    case competition = "competition"
    case rest = "rest"
    
    var displayName: String {
        switch self {
        case .practice:
            return "Practice"
        case .competition:
            return "Competition"
        case .rest:
            return "Rest Day"
        }
    }
    
    var icon: String {
        switch self {
        case .practice:
            return "figure.run"
        case .competition:
            return "trophy"
        case .rest:
            return "moon.zzz"
        }
    }
    
    var color: String {
        switch self {
        case .practice:
            return "blue"
        case .competition:
            return "orange"
        case .rest:
            return "purple"
        }
    }
} 