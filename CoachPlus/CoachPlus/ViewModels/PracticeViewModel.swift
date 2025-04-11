import Foundation
import SwiftUI

// Update PracticeViewState to conform to Equatable
enum PracticeViewState: Equatable {
    case idle
    case loading
    case error(Error)
    case success
    
    // Add Equatable conformance for error case
    static func == (lhs: PracticeViewState, rhs: PracticeViewState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.loading, .loading):
            return true
        case (.success, .success):
            return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

// Make PracticeError conform to Equatable
enum PracticeError: Error, Equatable {
    case invalidDate
    case invalidSections
    case saveFailed
    case loadFailed
    case deleteFailed
}

class PracticeViewModel: ObservableObject {
    @Published private(set) var state: PracticeViewState = .idle
    @Published var selectedDate: Date = Date()
    @Published var practices: [Practice] = [] {
        didSet {
            // Only need to update stats now
            statsViewModel.updatePractices(practices)
        }
    }
    @AppStorage("defaultPracticeTime") var defaultPracticeTime: Date = Calendar.current.date(from: DateComponents(hour: 15, minute: 30)) ?? Date()
    @Published var savedBlocks: [PracticeBlock] = [] {
        didSet {
            saveSavedBlocks()
        }
    }
    
    private let savedBlocksKey = "savedBlocks"
    
    let templateViewModel = TemplateViewModel()
    let monthlyFocusViewModel = MonthlyFocusViewModel()
    let statsViewModel = StatsViewModel()  // Add StatsViewModel
    
    // Add practice manager
    private let practiceManager = PracticeManager()
    
    init() {
        // Load initial practices from manager
        practices = practiceManager.getPractices()
        loadSavedBlocks()
        statsViewModel.updatePractices(practices)
        
        // Debug: Compare loaded practices
        let managerPractices = practiceManager.getPractices()
        print("📊 Existing practices count:", practices.count)
        print("📊 Manager practices count:", managerPractices.count)
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
    
    // Update methods to handle states
    func createPractice(
        date: Date,
        time: Date,
        type: PracticeType,
        sections: [String],
        intensity: Double,
        isFromTemplate: Bool = false,
        includesLift: Bool = false,
        liveTimeMinutes: Int = 0
    ) {
        state = .loading
        do {
            try practiceManager.createPractice(
                date: date,
                time: time,
                type: type,
                sections: sections,
                intensity: intensity,
                isFromTemplate: isFromTemplate,
                includesLift: includesLift,
                liveTimeMinutes: liveTimeMinutes
            )
            practices = practiceManager.getPractices()
            state = .success
        } catch {
            state = .error(error)
        }
    }
    
    // Update practiceForDate to use manager
    func practiceForDate(_ date: Date) -> Practice? {
        practiceManager.practiceForDate(date)
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
    
    func saveTemplate(
        name: String,
        sections: [String],
        intensity: Double,
        liveTimeMinutes: Int,
        includesLift: Bool,
        practiceTime: Date
    ) {
        let template = PracticeTemplate(
            name: name,
            sections: sections,
            intensity: intensity,
            liveTimeMinutes: liveTimeMinutes,
            includesLift: includesLift,
            practiceTime: practiceTime
        )
        templateViewModel.saveTemplate(template)
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
    
    // Update deletePractice to be cleaner
    func deletePractice(for date: Date) {
        practiceManager.deletePractice(for: date)
        practices = practiceManager.getPractices()
    }
    
    // Add createRecurringPractices wrapper
    func createRecurringPractices(
        startDate: Date,
        endDate: Date,
        pattern: RecurrencePattern,
        time: Date,
        type: PracticeType,
        sections: [String],
        intensity: Double,
        includesLift: Bool,
        liveTimeMinutes: Int
    ) {
        state = .loading
        do {
            try practiceManager.createRecurringPractices(
                startDate: startDate,
                endDate: endDate,
                pattern: pattern,
                time: time,
                type: type,
                sections: sections,
                intensity: intensity,
                includesLift: includesLift,
                liveTimeMinutes: liveTimeMinutes
            )
            practices = practiceManager.getPractices()
            state = .success
        } catch {
            state = .error(error)
        }
    }
    
    // Add this method back
    func savePractice(_ practice: Practice) {
        practiceManager.savePractice(practice)
        practices = practiceManager.getPractices()
    }
    
    @discardableResult
    func createPracticeFromTemplate(_ template: PracticeTemplate, date: Date, completion: ((Practice) -> Void)? = nil) -> Practice? {
        state = .loading
        do {
            let practice = try practiceManager.createPractice(
                date: date,
                time: defaultPracticeTime,
                type: .practice,
                sections: template.sections,
                intensity: template.intensity,
                isFromTemplate: true,
                includesLift: template.includesLift,
                liveTimeMinutes: template.liveTimeMinutes
            )
            practices = practiceManager.getPractices()
            state = .success
            completion?(practice)
            return practice
        } catch {
            state = .error(error)
            return nil
        }
    }
    
    func handleError(_ error: Error) {
        state = .error(error)
    }
} 
