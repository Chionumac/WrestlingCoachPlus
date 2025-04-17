import SwiftUI

struct PracticeQuickView: View {
    let practice: Practice?
    
    var body: some View {
        if let practice = practice {
            VStack(spacing: 12) {
                HStack(spacing: 0) {
                    // Left icon with fixed width
                    Image(systemName: practice.type == .rest ? "moon.zzz.fill" : "figure.run")
                        .font(.title2)
                        .foregroundStyle(practice.type == .rest ? Color.blue : Color.green)
                        .shadow(color: (practice.type == .rest ? Color.blue : Color.green).opacity(0.3), radius: 4)
                        .frame(width: 40)
                    
                    // Center content
                    if let firstSection = practice.sections.first, !firstSection.isEmpty {
                        Text(firstSection)
                            .font(.callout)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                    }
                    
                    // Timer badge
                    if practice.liveTimeMinutes > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "timer")
                                .font(.subheadline)
                                .foregroundStyle(.blue)
                            Text("\(practice.liveTimeMinutes)m")
                                .font(.caption)
                                .bold()
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                        )
                    }
                    
                    // Intensity badge with extra padding
                    if practice.type != .rest {
                        HStack(spacing: 2) {
                            Image(systemName: "flame.fill")
                                .font(.subheadline)
                                .foregroundStyle(Color.orange)
                            Text("\(Int(practice.intensity * 10))/10")
                                .font(.caption)
                                .bold()
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                        )
                        .padding(.leading, 8)
                        .padding(.trailing, 4)
                    }
                }
                .frame(maxHeight: 44) // Fixed height for vertical centering
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
            )
        } else {
            EmptyPracticeView()
        }
    }
}

struct CompetitionQuickView: View {
    let practice: Practice
    
    private var competitionDetails: (name: String, results: String, video: String, notes: String, performance: String) {
        var name = "", results = "", video = "", notes = "", performance = ""
        
        for section in practice.sections {
            if section.starts(with: "Competition: ") {
                name = section.replacingOccurrences(of: "Competition: ", with: "")
            } else if section.starts(with: "Results: ") {
                results = section.replacingOccurrences(of: "Results: ", with: "")
            } else if section.starts(with: "Video: ") {
                video = section.replacingOccurrences(of: "Video: ", with: "")
            } else if section.starts(with: "Performance: ") {
                performance = section.replacingOccurrences(of: "Performance: ", with: "")
            } else {
                notes = section
            }
        }
        
        return (name, results, video, notes, performance)
    }
    
    private func formatURL(_ urlString: String) -> URL? {
        if urlString.isEmpty { return nil }
        
        // If the URL doesn't start with a scheme, add https://
        if !urlString.starts(with: "http://") && !urlString.starts(with: "https://") {
            return URL(string: "https://" + urlString)
        }
        
        return URL(string: urlString)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Competition Name
            Text(competitionDetails.name)
                .font(.headline)
            
            // Links if available
            if !competitionDetails.results.isEmpty {
                if let url = formatURL(competitionDetails.results) {
                    Link(destination: url) {
                        HStack {
                            Label("Results", systemImage: "list.clipboard")
                                .foregroundStyle(.blue)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .foregroundStyle(.blue)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            
            if !competitionDetails.video.isEmpty {
                if let url = formatURL(competitionDetails.video) {
                    Link(destination: url) {
                        HStack {
                            Label("Video", systemImage: "video")
                                .foregroundStyle(.blue)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .foregroundStyle(.blue)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            
            // Notes if available
            if !competitionDetails.notes.isEmpty {
                Text(competitionDetails.notes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            // Performance - removed the text, keeping only the medal icon
            Image(systemName: "medal.fill")
                .foregroundStyle(.yellow)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct RegularPracticeQuickView: View {
    let practice: Practice
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(practice.sections, id: \.self) { block in
                Text(block)
                    .font(.subheadline)
            }
            
            HStack {
                Text("Intensity:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(String(format: "%.0f%%", practice.intensity * 100))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct EmptyPracticeView: View {
    var body: some View {
        HStack(spacing: 12) {
            // Calendar icon on left
            Image(systemName: "calendar")
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(width: 40)
            
            // Centered text
            Text("No practice scheduled")
                .font(.callout)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
            
            // Empty space matching width of badge area
            Spacer()
                .frame(width: 40)
        }
        .frame(maxHeight: 44)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
        )
    }
}

#Preview {
    VStack {
        PracticeQuickView(practice: nil)
        
        PracticeQuickView(practice: Practice(
            date: Date(),
            type: .competition,
            sections: [
                "Competition: National Championships",
                "Great performance overall!",
                "Results: https://results.com",
                "Video: https://video.com",
                "Performance: Excellent"
            ],
            intensity: 0.9,
            isFromTemplate: false
        ))
        
        PracticeQuickView(practice: Practice(
            date: Date(),
            type: .practice,
            sections: ["Warm up", "Main set", "Cool down"],
            intensity: 0.7,
            isFromTemplate: false
        ))
    }
} 
