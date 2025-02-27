import Foundation

class MockTemplateService: TemplateServiceProtocol {
    private var templates: [PracticeTemplate] = []
    private var _lastError: Error?
    
    var lastError: Error? { _lastError }
    var saveWasCalled = false
    var loadWasCalled = false
    var deleteWasCalled = false
    var shouldFail = false
    
    func save(_ template: PracticeTemplate) throws {
        saveWasCalled = true
        
        if shouldFail {
            _lastError = TemplateServiceError.saveFailed
            throw TemplateServiceError.saveFailed
        }
        
        templates.removeAll { $0.id == template.id }
        templates.append(template)
    }
    
    func load() -> [PracticeTemplate] {
        loadWasCalled = true
        return templates
    }
    
    func delete(_ template: PracticeTemplate) {
        deleteWasCalled = true
        templates.removeAll { $0.id == template.id }
    }
    
    func validate(_ template: PracticeTemplate) -> Bool {
        !template.name.isEmpty && !template.sections.isEmpty
    }
    
    func reset() {
        templates.removeAll()
        _lastError = nil
        saveWasCalled = false
        loadWasCalled = false
        deleteWasCalled = false
        shouldFail = false
    }
    
    func deleteAll() throws {
        if shouldFail {
            throw TemplateServiceError.deleteFailed
        }
        templates.removeAll()
    }
} 