import Foundation
import SwiftUI

class PracticeViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var practices: [Practice] = [] {
        didSet {
            savePractices()
        }
    }
    @Published var templates: [PracticeTemplate] = [] {
        didSet {
            saveTemplates()
        }
    }
    @Published var monthlyFocuses: [MonthlyFocus] = [] {
        didSet {
            saveMonthlyFocuses()
        }
    }
    @AppStorage("defaultPracticeTime") var defaultPracticeTime: Date = Calendar.current.date(from: DateComponents(hour: 15, minute: 30)) ?? Date()
    @Published var savedBlocks: [PracticeBlock] = [] {
        didSet {
            saveSavedBlocks()
        }
    }
    
    private let practicesKey = "savedPractices"
    private let templatesKey = "savedTemplates"
    private let monthlyFocusKey = "savedMonthlyFocuses"
    private let savedBlocksKey = "savedBlocks"
    
    init() {
        loadPractices()
        loadTemplates()
        loadMonthlyFocuses()
        loadSavedBlocks()
    }
    
    private func loadPractices() {
        if let data = UserDefaults.standard.data(forKey: practicesKey) {
            if let decoded = try? JSONDecoder().decode([Practice].self, from: data) {
                practices = decoded
                return
            }
        }
        practices = []
    }
    
    private func savePractices() {
        if let encoded = try? JSONEncoder().encode(practices) {
            UserDefaults.standard.set(encoded, forKey: practicesKey)
        }
    }
    
    private func loadTemplates() {
        if let data = UserDefaults.standard.data(forKey: templatesKey) {
            if let decoded = try? JSONDecoder().decode([PracticeTemplate].self, from: data) {
                templates = decoded
                return
            }
        }
        templates = []
    }
    
    private func saveTemplates() {
        if let encoded = try? JSONEncoder().encode(templates) {
            UserDefaults.standard.set(encoded, forKey: templatesKey)
        }
    }
    
    private func loadMonthlyFocuses() {
        if let data = UserDefaults.standard.data(forKey: monthlyFocusKey) {
            if let decoded = try? JSONDecoder().decode([MonthlyFocus].self, from: data) {
                monthlyFocuses = decoded
                return
            }
        }
        monthlyFocuses = []
    }
    
    private func saveMonthlyFocuses() {
        if let encoded = try? JSONEncoder().encode(monthlyFocuses) {
            UserDefaults.standard.set(encoded, forKey: monthlyFocusKey)
        }
    }
    
    private func loadSavedBlocks() {
        if let data = UserDefaults.standard.data(forKey: savedBlocksKey) {
            if let decoded = try? JSONDecoder().decode([PracticeBlock].self, from: data) {
                savedBlocks = decoded
                return
            }
        }
        savedBlocks = []
    }
    
    private func saveSavedBlocks() {
        if let encoded = try? JSONEncoder().encode(savedBlocks) {
            UserDefaults.standard.set(encoded, forKey: savedBlocksKey)
        }
    }
    
    func savePractice(_ practice: Practice) {
        // Remove any existing practice for this date
        practices.removeAll { Calendar.current.isDate($0.date, inSameDayAs: practice.date) }
        // Add the new practice
        practices.append(practice)
        // Data is automatically saved due to didSet
    }
    
    func practiceForDate(_ date: Date) -> Practice? {
        practices.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func intensityColor(for intensity: Double) -> Color {
        let hue = max(0, min(0.3, 0.3 - (intensity * 0.3)))  // Clamp between 0 and 0.3
        return Color(
            hue: hue,
            saturation: 0.7,
            brightness: 0.7
        )
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
        // Data is automatically saved due to didSet
    }
    
    func deletePractice(for date: Date) {
        practices.removeAll { Calendar.current.isDate($0.date, inSameDayAs: date) }
        // Data is automatically saved due to didSet
    }
    
    func monthlyFocus(for date: Date) -> MonthlyFocus? {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        return monthlyFocuses.first { $0.month == month && $0.year == year }
    }
    
    func saveMonthlyFocus(_ focus: MonthlyFocus) {
        monthlyFocuses.removeAll { $0.month == focus.month && $0.year == focus.year }
        monthlyFocuses.append(focus)
    }
    
    func saveBlock(_ block: PracticeBlock) {
        savedBlocks.append(block)
    }
    
    func deleteTemplate(_ template: PracticeTemplate) {
        templates.removeAll { $0.id == template.id }
    }
} 
