import SwiftUI

struct CompetitionSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: PracticeViewModel
    @State private var performanceThreshold: Double = 0.5
    @State private var selectedPractice: Practice? = nil
    @State private var showingPracticeEdit = false
    
    var filteredCompetitions: [Practice] {
        viewModel.practices.filter { practice in
            practice.type == .competition && practice.intensity >= performanceThreshold
        }.sorted { $0.intensity > $1.intensity }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if filteredCompetitions.isEmpty {
                    ContentUnavailableView(
                        "No Competitions Found",
                        systemImage: "trophy.fill",
                        description: Text("Try adjusting the performance filter")
                    )
                } else {
                    List {
                        ForEach(filteredCompetitions) { practice in
                            CompetitionSearchRow(practice: practice)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedPractice = practice
                                    showingPracticeEdit = true
                                }
                        }
                    }
                }
                
                // Performance Filter
                VStack(spacing: 8) {
                    Divider()
                    
                    HStack {
                        Text("Performance Filter")
                            .font(.headline)
                        Spacer()
                        Text(String(format: "%.0f%%", performanceThreshold * 100))
                            .foregroundStyle(.secondary)
                    }
                    
                    Slider(value: $performanceThreshold, in: 0...1) {
                        Text("Performance")
                    } minimumValueLabel: {
                        Text("0%")
                            .font(.caption)
                    } maximumValueLabel: {
                        Text("100%")
                            .font(.caption)
                    }
                    .tint(.orange)
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .navigationTitle("Competition Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showingPracticeEdit) {
                if let practice = selectedPractice {
                    AddCompetitionView(
                        date: practice.date,
                        viewModel: viewModel,
                        editingPractice: practice
                    ) {
                        // Refresh the view when done editing
                        selectedPractice = nil
                    }
                }
            }
        }
    }
}

struct CompetitionSearchRow: View {
    let practice: Practice
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var competitionName: String {
        practice.sections.first { section in
            section.starts(with: "Competition: ")
        }?.replacingOccurrences(of: "Competition: ", with: "") ?? "Unnamed Competition"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(competitionName)
                    .font(.headline)
                Spacer()
                Text(String(format: "%.0f%%", practice.intensity * 100))
                    .font(.subheadline.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(.systemGray6))
                    )
            }
            
            Text(dateFormatter.string(from: practice.date))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    CompetitionSearchView(viewModel: PracticeViewModel())
} 