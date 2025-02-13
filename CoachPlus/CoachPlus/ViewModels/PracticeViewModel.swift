import Foundation
import SwiftUI

class PracticeViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var practices: [Practice] = [] {
        didSet {
            savePractices()
            statsViewModel.updatePractices(practices)  // Update stats when practices change
        }
    }
    @AppStorage("defaultPracticeTime") var defaultPracticeTime: Date = Calendar.current.date(from: DateComponents(hour: 15, minute: 30)) ?? Date()
    @Published var savedBlocks: [PracticeBlock] = [] {
        didSet {
            saveSavedBlocks()
        }
    }
    
    private let practicesKey = "savedPractices"
    private let savedBlocksKey = "savedBlocks"
    
    let templateViewModel = TemplateViewModel()
    let monthlyFocusViewModel = MonthlyFocusViewModel()
    let statsViewModel = StatsViewModel()  // Add StatsViewModel
    
    init() {
        loadPractices()
        loadSavedBlocks()
        statsViewModel.updatePractices(practices)  // Initialize stats with current practices
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
    
    var templates: [PracticeTemplate] {
        templateViewModel.templates
    }
    
    func saveTemplate(name: String, sections: [String], intensity: Double, liveTimeMinutes: Int, includesLift: Bool, practiceTime: Date) {
        templateViewModel.saveTemplate(
            name: name,
            sections: sections,
            intensity: intensity,
            liveTimeMinutes: liveTimeMinutes,
            includesLift: includesLift,
            practiceTime: practiceTime
        )
    }
    
    func deleteTemplate(_ template: PracticeTemplate) {
        templateViewModel.deleteTemplate(template)
    }
    
    var monthlyFocuses: [MonthlyFocus] {
        monthlyFocusViewModel.monthlyFocuses
    }
    
    func monthlyFocus(for date: Date) -> MonthlyFocus? {
        monthlyFocusViewModel.monthlyFocus(for: date)
    }
    
    func saveMonthlyFocus(_ focus: MonthlyFocus) {
        monthlyFocusViewModel.saveMonthlyFocus(focus)
    }
    
    func saveBlock(_ block: PracticeBlock) {
        savedBlocks.append(block)
    }
    
    func deletePractice(for date: Date) {
        practices.removeAll { Calendar.current.isDate($0.date, inSameDayAs: date) }
        // Data is automatically saved due to didSet
    }
} 
