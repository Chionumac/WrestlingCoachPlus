import SwiftUI

class AppViewModel: ObservableObject {
    // Core Data
    @Published var practiceViewModel: PracticeViewModel
    
    // Navigation State
    @Published var showingAddPractice = false
    @Published var showingPracticeDetails = false
    @Published var showingMonthlyFocus = false
    @Published var showingSearchSheet = false
    @Published var showingDefaultTimeSetting = false
    @Published var showingTutorial = false
    
    // App State
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial = false
    @AppStorage("practiceViewBackground") var savedImageData: Data?
    
    init() {
        self.practiceViewModel = PracticeViewModel()
    }
    
    // MARK: - Navigation Methods
    func showAddPractice() {
        showingAddPractice = true
    }
    
    func showPracticeDetails() {
        showingPracticeDetails = true
    }
    
    // MARK: - App State Methods
    func checkAndShowTutorial() {
        if !hasSeenTutorial {
            showingTutorial = true
            hasSeenTutorial = true
        }
    }
} 