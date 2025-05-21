import SwiftUI

struct StatsBar: View {
    @ObservedObject var viewModel: StatsViewModel
    let selectedDate: Date
    @AppStorage("sliderMetricName") var sliderMetricName: String = "Avg Intensity"
    
    private var monthStats: StatsViewModel.Stats {
        viewModel.monthStats(for: selectedDate)
    }
    
    private var weekStats: StatsViewModel.Stats {
        viewModel.weekStats(for: selectedDate)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Top Row
            HStack(spacing: 12) {
                // Monthly Practice Count
                StatItem(
                    icon: "figure.run",
                    value: "\(monthStats.practices)",
                    label: "Practices",
                    color: .green
                )
                
                // Monthly Rest Days
                StatItem(
                    icon: "moon.zzz.fill",
                    value: "\(monthStats.rest)",
                    label: "Rest Days",
                    color: .blue
                )
                
                // Monthly Competitions
                StatItem(
                    icon: "trophy.fill",
                    value: "\(monthStats.competitions)",
                    label: "Competitions",
                    color: .green
                )
                
                // Monthly Lifts
                StatItem(
                    icon: "dumbbell.fill",
                    value: "\(monthStats.lifts)",
                    label: "Lifts",
                    color: .blue
                )
            }
            
            // Bottom Row
            HStack(spacing: 12) {
                // Monthly Live Time
                StatItem(
                    icon: "timer",
                    value: "\(monthStats.liveTime)",
                    label: "Month Live",
                    color: .blue
                )
                
                // Monthly Intensity (custom label)
                StatItem(
                    icon: "flame.fill",
                    value: "\(Int(monthStats.intensity * 10))/10",
                    label: "Month \(sliderMetricName)",
                    color: .green
                )
                
                // Weekly Live Time
                StatItem(
                    icon: "timer",
                    value: "\(weekStats.liveTime)",
                    label: "Week Live",
                    color: .blue
                )
                
                // Weekly Intensity (custom label)
                StatItem(
                    icon: "flame.fill",
                    value: "\(Int(weekStats.intensity * 10))/10",
                    label: "Week \(sliderMetricName)",
                    color: .green
                )
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .frame(height: 200)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .shadow(
                    color: .black.opacity(0.2),
                    radius: 10,
                    x: 0,
                    y: 4
                )
        )
        .padding(.horizontal)
    }
}

// Add StatItem view definition
struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color)
                .shadow(color: color.opacity(0.3), radius: 2)
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 15, weight: .bold))
                
                Text(label)
                    .font(.system(size: 10))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 70)
        .padding(.vertical, 6)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        )
    }
} 
