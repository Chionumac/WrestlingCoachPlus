import SwiftUI

struct CompetitionDetails {
    var name: String = ""
    var resultsURL: String = ""
    var videoURL: String = ""
    var notes: String = ""
    var performance: Double = 0.5
}

struct AddCompetitionView: View {
    let date: Date
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var viewModel: PracticeViewModel
    let editingPractice: Practice?
    let onSave: () -> Void
    
    @State private var name = ""
    @State private var results = ""
    @State private var video = ""
    @State private var notes = ""
    @State private var performanceNote = ""
    @State private var performanceRating = 0.8
    @State private var selectedDates: Set<Date> = []
    @State private var showingDatePicker = false
    @State private var showingDeleteConfirmation = false
    @State private var isDeleting = false
    @State private var isDismissing = false
    @State private var practiceTime = Date()
    
    init(
        date: Date,
        viewModel: PracticeViewModel,
        editingPractice: Practice? = nil,
        onSave: @escaping () -> Void = {}
    ) {
        self.date = date
        self.viewModel = viewModel
        self.editingPractice = editingPractice
        self.onSave = onSave
        
        if let practice = editingPractice {
            _name = State(initialValue: practice.sections.first?.replacingOccurrences(of: "Competition: ", with: "") ?? "")
            _performanceNote = State(initialValue: practice.sections.last?.replacingOccurrences(of: "Performance: ", with: "") ?? "")
            _performanceRating = State(initialValue: practice.intensity)
            _selectedDates = State(initialValue: [practice.date])
            
            for section in practice.sections {
                if section.starts(with: "Results: ") {
                    _results = State(initialValue: section.replacingOccurrences(of: "Results: ", with: ""))
                } else if section.starts(with: "Video: ") {
                    _video = State(initialValue: section.replacingOccurrences(of: "Video: ", with: ""))
                } else if !section.starts(with: "Competition: ") && !section.starts(with: "Performance: ") {
                    _notes = State(initialValue: section)
                }
            }
        } else {
            _selectedDates = State(initialValue: [date])
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter
    }()
    
    private var resultsURL: URL? {
        URL(string: results)
    }
    
    private var videoURL: URL? {
        URL(string: video)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DateHeaderView(date: date, practiceTime: $practiceTime)
            
            Form {
                Section {
                    TextField("Competition Name", text: $name)
                    
                    Button(action: { showingDatePicker = true }) {
                        HStack {
                            Text("Competition Dates")
                            Spacer()
                            Text("\(selectedDates.count) selected")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Section {
                    URLInputField(
                        urlString: $results,
                        placeholder: "Results URL",
                        iconName: "arrow.up.right",
                        linkText: "Open Results"
                    )
                    
                    URLInputField(
                        urlString: $video,
                        placeholder: "Video URL",
                        iconName: "arrow.up.right",
                        linkText: "Open Video"
                    )
                    
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    VStack(spacing: 16) {
                        RatingSliderView(rating: $performanceRating, title: "Performance")
                        
                        // Save button
                        Button("Save Competition") {
                            savePractice()
                            onSave()
                            dismiss()
                        }
                        .gradientButtonStyle(isDisabled: name.isEmpty)
                        .disabled(name.isEmpty)
                    }
                }
            }
            .listSectionSpacing(.compact)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text(editingPractice == nil ? "Add Competition" : "Edit Competition")
                    .navigationTitleStyle()
            }
            
            ToolbarItem(placement: .keyboard) {
                Button(action: {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                 to: nil, from: nil, for: nil)
                }) {
                    Image(systemName: "keyboard.chevron.compact.down")
                        .foregroundStyle(.blue)
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                if editingPractice != nil {
                    Menu {
                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            Label("Delete Competition", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.blue)
                            .shadow(color: .blue.opacity(0.3), radius: 4)
                    }
                }
            }
        }
        .deleteConfirmation(
            title: "Delete Competition",
            message: "Are you sure you want to delete this competition? This action cannot be undone.",
            isPresented: $showingDeleteConfirmation
        ) {
            isDeleting = true
            if editingPractice != nil {
                // Delete all dates for this competition
                for date in selectedDates {
                    viewModel.deletePractice(for: date)
                }
            }
            onSave()
            dismiss()
        }
        .sheet(isPresented: $showingDatePicker) {
            NavigationStack {
                MultiDatePicker(selectedDates: $selectedDates)
                    .navigationTitle("Select Dates")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showingDatePicker = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                showingDatePicker = false
                            }
                        }
                    }
            }
            .presentationDetents([.medium])
        }
        .presentationDetents([.large])
        .interactiveDismissDisabled(false)
        .onDisappear {
            if !name.isEmpty && !isDeleting {
                savePractice()
                onSave()
            }
        }
        .onChange(of: presentationMode.wrappedValue.isPresented) { oldValue, newValue in
            if !newValue && !isDismissing {
                isDismissing = true
                if !name.isEmpty && !isDeleting {
                    savePractice()
                    onSave()
                }
            }
        }
    }
    
    private func savePractice() {
        let sections = [
            "Competition: \(name)",
            results.isEmpty ? nil : "Results: \(results)",
            video.isEmpty ? nil : "Video: \(video)",
            notes.isEmpty ? nil : notes,
            performanceNote.isEmpty ? nil : "Performance: \(performanceNote)"
        ].compactMap { $0 }
        
        // Save a practice for each selected date
        for date in selectedDates {
            let practice = Practice(
                id: date == self.date ? (editingPractice?.id ?? UUID()) : UUID(),
                date: date,
                type: .competition,
                sections: sections,
                intensity: performanceRating,
                isFromTemplate: false
            )
            viewModel.savePractice(practice)
        }
    }
    
    private func saveRecurringPractices() {
        // Implementation of saveRecurringPractices method
    }
}

#Preview {
    NavigationStack {
        AddCompetitionView(
            date: Date(),
            viewModel: PracticeViewModel()
        ) {
            // Placeholder for onSave
        }
    }
} 
