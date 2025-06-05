import SwiftUI

struct UnifiedSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: PracticeViewModel
    @State private var searchText = ""
    @State private var selectedFilter: SearchFilter = .all
    @State private var performanceThreshold: Double = 0.0
    @State private var selectedPractice: Practice? = nil
    
    enum SearchFilter {
        case all
        case practices
        case competitions
    }
    
    var filteredResults: [Practice] {
        let results = viewModel.practices.filter { practice in
            if searchText.isEmpty {
                return true
            }
            return practice.sections.joined(separator: " ")
                .localizedCaseInsensitiveContains(searchText)
        }
        
        let filteredByType = results.filter { practice in
            switch selectedFilter {
            case .all: return true
            case .practices: return practice.type == .practice
            case .competitions: return practice.type == .competition
            }
        }
        
        if selectedFilter == .competitions {
            return filteredByType.filter { $0.intensity >= performanceThreshold }
        }
        
        return filteredByType.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Picker
                Picker("Filter", selection: $selectedFilter) {
                    Text("All").tag(SearchFilter.all)
                    Text("Practices").tag(SearchFilter.practices)
                    Text("Competitions").tag(SearchFilter.competitions)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Performance Filter (only for competitions)
                if selectedFilter == .competitions {
                    VStack(spacing: 8) {
                        HStack {
                            Text("Performance Filter")
                                .font(.subheadline)
                            Spacer()
                            Text("\(Int(performanceThreshold * 100))%")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Slider(value: $performanceThreshold, in: 0...1) {
                            Text("Performance")
                        }
                        .tint(.orange)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                }
                
                if filteredResults.isEmpty {
                    ContentUnavailableView(
                        "No Results",
                        systemImage: "magnifyingglass",
                        description: Text("Try adjusting your search or filters")
                    )
                } else {
                    List {
                        ForEach(filteredResults) { practice in
                            SearchResultRow(practice: practice)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedPractice = practice
                                }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search practices and competitions")
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(item: $selectedPractice) { practice in
                    if practice.type == .competition {
                        AddCompetitionView(
                            date: practice.date,
                            viewModel: viewModel,
                            editingPractice: practice
                        ) {
                            selectedPractice = nil
                        }
                    } else {
                        PracticeEntryView(
                            date: practice.date,
                            viewModel: viewModel,
                            editingPractice: practice
                        ) {
                            selectedPractice = nil
                    }
                }
            }
        }
    }
}

struct SearchResultRow: View {
    let practice: Practice
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Icon based on practice type
                Image(systemName: practice.type == .competition ? "trophy.fill" : "figure.run")
                    .foregroundStyle(practice.type == .competition ? .orange : .green)
                
                Text(practice.sections.first ?? "")
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