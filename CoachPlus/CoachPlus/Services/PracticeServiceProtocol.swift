import Foundation

protocol PracticeServiceProtocol {
    // Core operations
    func save(_ practice: Practice) throws
    func load() -> [Practice]
    func delete(for date: Date)
    func getPractice(for date: Date) -> Practice?
    
    // Batch operations
    func saveMultiple(_ practices: [Practice]) throws
    func deleteAll() throws
    
    // Validation
    func validate(_ practice: Practice) -> Bool
    
    // Error handling
    var lastError: Error? { get }
}

// Define specific service errors
enum PracticeServiceError: Error {
    case invalidPractice
    case saveFailed
    case loadFailed
    case deleteFailed
    case dateConflict
    case storageError
} 