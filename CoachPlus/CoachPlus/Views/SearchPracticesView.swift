import SwiftUI

struct SearchPracticesView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: PracticeViewModel
    @State private var searchText = ""
    @State private var selectedPractice: Practice? = nil
    @State private var showingPracticeEdit = false
    
    var filteredPractices: [Practice] {
        if searchText.isEmpty {
            return viewModel.practices.sorted { $0.date > $1.date }
        } else {
            return viewModel.practices.filter { practice in
                practice.sections.joined(separator: " ")
                    .localizedCaseInsensitiveContains(searchText)
            }.sorted { $0.date > $1.date }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if filteredPractices.isEmpty {
                    ContentUnavailableView(
                        "No Practices Found",
                        systemImage: "magnifyingglass",
                        description: Text("Try a different search term")
                    )
                } else {
                    List {
                        ForEach(filteredPractices) { practice in
                            SearchPracticeRow(practice: practice)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedPractice = practice
                                    showingPracticeEdit = true
                                }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search practices")
            .navigationTitle("Search Practices")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showingPracticeEdit) {
                if let practice = selectedPractice {
                    PracticeEntryView(
                        date: practice.date,
                        viewModel: viewModel,
                        editingPractice: practice,
                        practiceType: practice.type
                    ) {
                        // Refresh the view when done editing
                        selectedPractice = nil
                    }
                }
            }
        }
    }
}

struct SearchPracticeRow: View {
    let practice: Practice
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
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