import Foundation
import SwiftUI

class TemplateViewModel: ObservableObject, PersistableViewModel {
    typealias DataType = [PracticeTemplate]
    
    let storageKey = "savedTemplates"
    
    @Published private(set) var state: PracticeViewState = .idle
    @Published private(set) var templates: [PracticeTemplate] = []
    @Published var data: [PracticeTemplate] = []  // Add this if required by protocol
    
    private let service: TemplateServiceProtocol
    
    init(service: TemplateServiceProtocol = UserDefaultsTemplateService()) {
        self.service = service
        loadTemplates()
    }
    
    // MARK: - PersistableViewModel
    func load() -> [PracticeTemplate]? {
        service.load()
    }
    
    func save(_ data: [PracticeTemplate]) {
        for template in data {
            try? service.save(template)
        }
    }
    
    func deleteAll() {
        try? service.deleteAll()
        templates.removeAll()
    }
    
    // MARK: - Template Operations
    func loadTemplates() {
        state = .loading
        templates = service.load()
        state = .success
    }
    
    func saveTemplate(_ template: PracticeTemplate) {
        state = .loading
        do {
            try service.save(template)
            templates = service.load()
            state = .success
        } catch {
            state = .error(error)
        }
    }
    
    func deleteTemplate(_ template: PracticeTemplate) {
        state = .loading
        service.delete(template)
        templates = service.load()
        state = .success
    }
} 