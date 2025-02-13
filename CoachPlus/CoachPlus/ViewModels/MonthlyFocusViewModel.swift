import Foundation
import SwiftUI

class MonthlyFocusViewModel: ObservableObject {
    @Published var monthlyFocuses: [MonthlyFocus] = [] {
        didSet {
            save(monthlyFocuses)
        }
    }
    
    internal let storageKey = "savedMonthlyFocuses"
    
    init() {
        monthlyFocuses = load() ?? []
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
}

extension MonthlyFocusViewModel: PersistableViewModel {
    typealias DataType = [MonthlyFocus]
} 