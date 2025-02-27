import Foundation

protocol TemplateServiceProtocol {
    // Core operations
    func save(_ template: PracticeTemplate) throws
    func load() -> [PracticeTemplate]
    func delete(_ template: PracticeTemplate)
    func deleteAll() throws
    
    // Validation
    func validate(_ template: PracticeTemplate) -> Bool
    
    // Error handling
    var lastError: Error? { get }
}

enum TemplateServiceError: Error {
    case invalidTemplate
    case saveFailed
    case loadFailed
    case deleteFailed
} 