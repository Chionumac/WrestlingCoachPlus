import SwiftUI

struct MonthlyStatsSheet: View {
    let stats: MonthlyStats
    var onDismiss: (() -> Void)? = nil

    private var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: stats.month)
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Your Stats for \(monthString)")
                .font(.title2)
                .bold()
                .padding(.top)

            HStack(spacing: 32) {
                StatBlock(title: "Practices", value: "\(stats.practiceCount)", color: .blue)
                StatBlock(title: "Competitions", value: "\(stats.competitionCount)", color: .orange)
            }

            HStack(spacing: 32) {
                StatBlock(title: "Avg Intensity", value: String(format: "%.1f/10", stats.averageIntensity * 10), color: .green)
                StatBlock(title: "Live Minutes", value: "\(stats.totalLiveTime)", color: .purple)
            }

            HStack(spacing: 32) {
                StatBlock(title: "Lifts", value: "\(stats.liftCount)", color: .pink)
                StatBlock(title: "Rest Days", value: "\(stats.restDayCount)", color: .gray)
            }

            Spacer()

            Button("Dismiss") {
                onDismiss?()
            }
            .padding()
        }
        .padding()
        .presentationDetents([.medium, .large])
    }
}

struct StatBlock: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack {
            Text(value)
                .font(.title)
                .bold()
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 100, height: 60)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    MonthlyStatsSheet(stats: MonthlyStats(
        month: Date(),
        practiceCount: 12,
        competitionCount: 2,
        averageIntensity: 0.75,
        totalLiveTime: 340,
        liftCount: 5,
        restDayCount: 3
    ))
} 