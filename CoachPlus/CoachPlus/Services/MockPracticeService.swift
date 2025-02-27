import Foundation

class MockPracticeService: PracticeServiceProtocol {
    private var practices: [Practice] = []
    private var _lastError: Error?
    
    var lastError: Error? { _lastError }
    var saveWasCalled = false
    var loadWasCalled = false
    var deleteWasCalled = false
    
    // For testing specific scenarios
    var shouldFail = false
    
    func save(_ practice: Practice) throws {
        saveWasCalled = true
        
        if shouldFail {
            _lastError = PracticeServiceError.saveFailed
            throw PracticeServiceError.saveFailed
        }
        
        practices.removeAll { Calendar.current.isDate($0.date, inSameDayAs: practice.date) }
        practices.append(practice)
    }
    
    func load() -> [Practice] {
        loadWasCalled = true
        return practices
    }
    
    func delete(for date: Date) {
        deleteWasCalled = true
        practices.removeAll { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func getPractice(for date: Date) -> Practice? {
        practices.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func saveMultiple(_ practices: [Practice]) throws {
        if shouldFail {
            throw PracticeServiceError.saveFailed
        }
        for practice in practices {
            try save(practice)
        }
    }
    
    func deleteAll() throws {
        if shouldFail {
            throw PracticeServiceError.deleteFailed
        }
        practices.removeAll()
    }
    
    func validate(_ practice: Practice) -> Bool {
        practice.isValid
    }
    
    // Helper method to reset the mock state
    func reset() {
        practices.removeAll()
        _lastError = nil
        saveWasCalled = false
        loadWasCalled = false
        deleteWasCalled = false
        shouldFail = false
    }
} 