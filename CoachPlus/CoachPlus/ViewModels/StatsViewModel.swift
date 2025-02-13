import Foundation
import SwiftUI

class StatsViewModel: ObservableObject {
    @Published var practices: [Practice] = []
    
    // Basic stats structure
    struct Stats {
        let practices: Int
        let rest: Int
        let competitions: Int
        let lifts: Int
        let liveTime: Int
        let intensity: Double
    }
    
    func monthStats(for date: Date) -> Stats {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        let monthPractices = practices.filter {
            let practiceMonth = calendar.component(.month, from: $0.date)
            let practiceYear = calendar.component(.year, from: $0.date)
            return practiceMonth == month && practiceYear == year
        }
        
        let practiceCount = monthPractices.filter { $0.type == .regular }.count
        let restCount = monthPractices.filter { $0.type == .rest }.count
        let competitions = monthPractices.filter { $0.type == .competition }
        let uniqueCompetitions = Set(competitions.compactMap { practice -> String? in
            practice.sections.first { section in
                section.starts(with: "Competition: ")
            }?.replacingOccurrences(of: "Competition: ", with: "")
        })
        let liftCount = monthPractices.filter { $0.includesLift }.count
        
        let avgIntensity = monthPractices
            .filter { $0.type != .rest && $0.type != .competition }
            .map { $0.intensity }
            .reduce(0.0, +) / Double(max(practiceCount, 1))
        
        let totalLiveTime = monthPractices
            .map { $0.liveTimeMinutes }
            .reduce(0, +)
        
        return Stats(
            practices: practiceCount,
            rest: restCount,
            competitions: uniqueCompetitions.count,
            lifts: liftCount,
            liveTime: totalLiveTime,
            intensity: avgIntensity
        )
    }
    
    func weekStats(for date: Date) -> Stats {
        let calendar = Calendar.current
        let weekOfYear = calendar.component(.weekOfYear, from: date)
        let year = calendar.component(.year, from: date)
        
        let weekPractices = practices.filter {
            let practiceWeek = calendar.component(.weekOfYear, from: $0.date)
            let practiceYear = calendar.component(.year, from: $0.date)
            return practiceWeek == weekOfYear && practiceYear == year
        }
        
        let regularPractices = weekPractices.filter { $0.type != .rest && $0.type != .competition }
        let avgIntensity = regularPractices.isEmpty ? 0.0 :
            regularPractices.map { $0.intensity }.reduce(0.0, +) / Double(regularPractices.count)
        
        let totalLiveTime = weekPractices
            .map { $0.liveTimeMinutes }
            .reduce(0, +)
        
        return Stats(
            practices: regularPractices.count,
            rest: weekPractices.filter { $0.type == .rest }.count,
            competitions: weekPractices.filter { $0.type == .competition }.count,
            lifts: weekPractices.filter { $0.includesLift }.count,
            liveTime: totalLiveTime,
            intensity: avgIntensity
        )
    }
    
    func updatePractices(_ practices: [Practice]) {
        self.practices = practices
    }
} 