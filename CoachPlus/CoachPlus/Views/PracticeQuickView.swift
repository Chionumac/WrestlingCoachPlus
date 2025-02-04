import SwiftUI

struct PracticeQuickView: View {
    let practice: Practice?
    
    var body: some View {
        if let practice = practice {
            VStack(spacing: 16) {
                // Header with practice icon and type
                HStack {
                    Image(systemName: practice.type == .rest ? "moon.zzz.fill" : "figure.run")
                        .font(.title2)
                        .foregroundStyle(practice.type == .rest ? Color.blue : Color.green)
                        .shadow(color: (practice.type == .rest ? Color.blue : Color.green).opacity(0.3), radius: 4)
                    
                    Text(practice.type == .rest ? "Rest Day" : "Practice")
                        .font(.headline)
                    
                    Spacer()
                    
                    // Live Time and Intensity Row
                    HStack {
                        if practice.liveTimeMinutes > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "timer")
                                    .foregroundStyle(.blue)
                                    .shadow(color: Color.blue.opacity(0.3), radius: 4)
                                Text("\(practice.liveTimeMinutes)min")
                                    .font(.subheadline)
                                    .bold()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                            )
                        }
                        
                        Spacer()
                        
                        // Intensity badge
                        if practice.type != .rest {
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .foregroundStyle(Color.orange)
                                    .shadow(color: Color.orange.opacity(0.3), radius: 4)
                                Text("\(Int(practice.intensity * 10))/10")
                                    .font(.subheadline)
                                    .bold()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                            )
                        }
                    }
                }
                
                // Show first section if available
                if let firstSection = practice.sections.first, !firstSection.isEmpty {
                    Text(firstSection)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
              
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
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
        VStack(spacing: 12) {
            Image(systemName: "calendar")
                .font(.title)
                .foregroundStyle(.secondary)
            
            Text("No practice scheduled")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
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
            type: .regular,
            sections: ["Warm up", "Main set", "Cool down"],
            intensity: 0.7,
            isFromTemplate: false
        ))
    }
} 
