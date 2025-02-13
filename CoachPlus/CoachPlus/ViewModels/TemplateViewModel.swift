import Foundation
import SwiftUI

class TemplateViewModel: ObservableObject {
    @Published var templates: [PracticeTemplate] = [] {
        didSet {
            save(templates)
        }
    }
    
    internal let storageKey = "savedTemplates"
    
    init() {
        templates = load() ?? []
    }
    
    func saveTemplate(name: String, sections: [String], intensity: Double, liveTimeMinutes: Int, includesLift: Bool, practiceTime: Date) {
        let template = PracticeTemplate(
            name: name,
            sections: sections,
            intensity: intensity,
            liveTimeMinutes: liveTimeMinutes,
            includesLift: includesLift,
            practiceTime: practiceTime
        )
        templates.append(template)
    }
    
    func deleteTemplate(_ template: PracticeTemplate) {
        templates.removeAll { $0.id == template.id }
    }
}

extension TemplateViewModel: PersistableViewModel {
    typealias DataType = [PracticeTemplate]
} 