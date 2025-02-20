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
            // Date subheader
            Text(dateFormatter.string(from: date))
                .font(.title2.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
            
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
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Results URL", text: $results)
                        if let url = URL(string: results) {
                            Link(destination: url) {
                                HStack {
                                    Label("Open Results", systemImage: "arrow.up.right")
                                        .font(.subheadline)
                                    Spacer()
                                }
                                .foregroundStyle(.blue)
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Video URL", text: $video)
                        if let url = URL(string: video) {
                            Link(destination: url) {
                                HStack {
                                    Label("Open Video", systemImage: "arrow.up.right")
                                        .font(.subheadline)
                                    Spacer()
                                }
                                .foregroundStyle(.blue)
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    VStack(spacing: 16) {
                        VStack(spacing: 8) {
                            HStack {
                                Text("Performance")
                                Spacer()
                                Text("\(Int(performanceRating * 10))/10")
                                    .foregroundStyle(.secondary)
                            }
                            
                            Slider(value: $performanceRating, in: 0...1) {
                                Text("Performance")
                            } minimumValueLabel: {
                                Text("Poor")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            } maximumValueLabel: {
                                Text("Great")
                                    .font(.caption)
                                    .foregroundStyle(.green)
                            }
                            .tint(
                                Color(
                                    hue: 0.3 * performanceRating,
                                    saturation: 0.8,
                                    brightness: 0.9
                                )
                            )
                        }
                        
                        // Save button
                        Button("Save Competition") {
                            savePractice()
                            onSave()
                            dismiss()
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .green.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .foregroundStyle(.white)
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .tracking(1)
                        .disabled(name.isEmpty)
                    }
                }
                
                // Only show delete section when editing
                if editingPractice != nil {
                    Section {
                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete Competition")
                            }
                            .frame(maxWidth: .infinity)
                            .font(.system(.body, design: .rounded, weight: .semibold))
                        }
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
                    .font(.system(.subheadline, design: .rounded, weight: .heavy))
                    .tracking(2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .green.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
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
        }
        .alert("Delete Competition", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if editingPractice != nil {
                    // Delete all dates for this competition
                    for date in selectedDates {
                        viewModel.deletePractice(for: date)
                    }
                }
                onSave()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this competition? This action cannot be undone.")
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

struct MultiDatePicker: View {
    @Binding var selectedDates: Set<Date>
    @Environment(\.calendar) private var calendar
    private let gridColumns = Array(repeating: GridItem(.flexible()), count: 7)
    
    @State private var displayedMonth = Date()
    
    var body: some View {
        VStack(spacing: 20) {
            // Month selector
            HStack {
                Button(action: { moveMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .imageScale(.large)
                }
                
                Spacer()
                
                Text(displayedMonth.formatted(.dateTime.month().year()))
                    .font(.title3.bold())
                
                Spacer()
                
                Button(action: { moveMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .imageScale(.large)
                }
            }
            .padding(.horizontal)
            
            // Weekday headers
            LazyVGrid(columns: gridColumns) {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                    Text(day.prefix(1))
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: gridColumns, spacing: 8) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        DayButton(
                            date: date,
                            isSelected: selectedDates.contains { 
                                calendar.isDate($0, inSameDayAs: date)
                            }
                        ) {
                            toggleDate(date)
                        }
                    } else {
                        Color.clear
                            .aspectRatio(1, contentMode: .fill)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func moveMonth(by value: Int) {
        if let newDate = calendar.date(
            byAdding: .month,
            value: value,
            to: displayedMonth
        ) {
            displayedMonth = newDate
        }
    }
    
    private func toggleDate(_ date: Date) {
        if selectedDates.contains(where: { calendar.isDate($0, inSameDayAs: date) }) {
            selectedDates.remove(date)
        } else {
            selectedDates.insert(date)
        }
    }
    
    private func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth) else {
            return []
        }
        
        let firstDayOfMonth = monthInterval.start
        let lastDayOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDayOfMonth)!
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let offsetFromSunday = firstWeekday - 1
        
        let lastWeekday = calendar.component(.weekday, from: lastDayOfMonth)
        let daysToSaturday = 7 - lastWeekday
        
        var days: [Date?] = []
        
        // Add empty days at start
        for _ in 0..<offsetFromSunday {
            days.append(nil)
        }
        
        // Add all days in month
        let numberOfDays = calendar.component(.day, from: lastDayOfMonth)
        for dayOffset in 0..<numberOfDays {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        // Add empty days at end
        for _ in 0..<daysToSaturday {
            days.append(nil)
        }
        
        return days
    }
}

struct DayButton: View {
    let date: Date
    let isSelected: Bool
    let action: () -> Void
    
    @Environment(\.calendar) private var calendar
    
    private var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    var body: some View {
        Button(action: action) {
            Text("\(calendar.component(.day, from: date))")
                .font(.callout)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundStyle(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fill)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? .blue : .clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(isToday ? .blue : .clear, lineWidth: 1)
                )
        }
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
