import Foundation

struct PracticeBlock: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var content: String
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        title: String = "",
        content: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
    }
    
    // Computed Properties
    var isEmpty: Bool {
        title.isEmpty && content.isEmpty
    }
    
    var displayTitle: String {
        title.isEmpty ? "Untitled Block" : title
    }
    
    // Validation
    var isValid: Bool {
        !content.isEmpty
    }
    
    // Convenience Methods
    func formattedForPractice() -> String {
        if title.isEmpty {
            return content
        }
        return "\(title): \(content)"
    }
} 