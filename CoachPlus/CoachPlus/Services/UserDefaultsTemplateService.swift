import Foundation

class UserDefaultsTemplateService: TemplateServiceProtocol {
    private let storageKey = "savedTemplates"
    private var _lastError: Error?
    
    var lastError: Error? { _lastError }
    
    func save(_ template: PracticeTemplate) throws {
        var templates = load()
        templates.removeAll { $0.id == template.id }
        templates.append(template)
        
        do {
            let encoded = try JSONEncoder().encode(templates)
            UserDefaults.standard.set(encoded, forKey: storageKey)
        } catch {
            _lastError = TemplateServiceError.saveFailed
            throw TemplateServiceError.saveFailed
        }
    }
    
    func load() -> [PracticeTemplate] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return []
        }
        
        do {
            return try JSONDecoder().decode([PracticeTemplate].self, from: data)
        } catch {
            _lastError = TemplateServiceError.loadFailed
            return []
        }
    }
    
    func delete(_ template: PracticeTemplate) {
        var templates = load()
        templates.removeAll { $0.id == template.id }
        
        do {
            let encoded = try JSONEncoder().encode(templates)
            UserDefaults.standard.set(encoded, forKey: storageKey)
        } catch {
            _lastError = TemplateServiceError.deleteFailed
        }
    }
    
    func validate(_ template: PracticeTemplate) -> Bool {
        !template.name.isEmpty && !template.sections.isEmpty
    }
    
    func deleteAll() throws {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
} 