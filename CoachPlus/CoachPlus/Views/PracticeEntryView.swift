import SwiftUI

struct PracticeBlock: Identifiable, Codable {
    var id = UUID()
    var title: String = ""
    var content: String = ""
}

struct PracticeEntryView: View {
    let date: Date
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode
    @State private var sections: [String]
    @State private var intensity: Double
    @State private var showingSaveTemplate = false
    @State private var templateName = ""
    @State private var includesLift: Bool
    @State private var liveTimeMinutes: Int
    @State private var recurrencePattern: RecurrencePattern = .none
    @State private var recurrenceEndDate = Date()
    @State private var showingRecurrenceOptions = false
    @ObservedObject var viewModel: PracticeViewModel
    let editingPractice: Practice?
    let practiceType: PracticeType
    let onSave: () -> Void
    
    @State private var summary: String = ""
    @State private var practiceTime: Date
    @State private var showingSummaryError = false
    @State private var blocks: [PracticeBlock] = [PracticeBlock()]  // Start with one empty block
    @State private var showingBlockSearch = false
    @State private var selectedBlockId: UUID? = nil
    @State private var isDeleting = false
    @State private var isDismissing = false
    
    init(
        date: Date,
        viewModel: PracticeViewModel,
        editingPractice: Practice? = nil,
        practiceType: PracticeType = .regular,
        onSave: @escaping () -> Void = {}
    ) {
        self.date = date
        self.viewModel = viewModel
        self.editingPractice = editingPractice
        self.practiceType = practiceType
        self.onSave = onSave
        
        // Initialize with editing practice time or default time
        _practiceTime = State(initialValue: editingPractice?.date ?? viewModel.defaultPracticeTime)
        
        // Initialize summary and details from the first two sections if editing
        if let practice = editingPractice {
            _summary = State(initialValue: practice.sections.first ?? "")
        }
        
        _sections = State(initialValue: editingPractice?.sections ?? practiceType.defaultSections)
        _intensity = State(initialValue: editingPractice?.intensity ?? 0.5)
        _includesLift = State(initialValue: editingPractice?.includesLift ?? false)
        _liveTimeMinutes = State(initialValue: editingPractice?.liveTimeMinutes ?? 0)
        
        // Initialize blocks from practice sections if editing
        if let practice = editingPractice {
            var initialBlocks: [PracticeBlock] = []
            for section in practice.sections.dropFirst() {  // Skip the first section
                if let separatorIndex = section.firstIndex(of: ":") {
                    let title = String(section[..<separatorIndex])
                    let content = String(section[section.index(after: separatorIndex)...]).trimmingCharacters(in: .whitespaces)
                    initialBlocks.append(PracticeBlock(title: title, content: content))
                } else {
                    initialBlocks.append(PracticeBlock(content: section))
                }
            }
            _blocks = State(initialValue: initialBlocks.isEmpty ? [PracticeBlock()] : initialBlocks)
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Date subheader
                HStack {
                    Text(dateFormatter.string(from: date))
                        .font(.title2.weight(.medium))
                    
                    Spacer()
                    
                    DatePicker("", selection: $practiceTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .font(.title2.weight(.medium))
                        .tint(.secondary)
                }
                .foregroundStyle(.secondary)
                .padding(.vertical, 12)
                .padding(.horizontal)
                .padding(.bottom, 4)
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                
                if practiceType == .rest {
                    // Rest Day View
                    VStack {
                        Image(systemName: "moon.zzz.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.purple)
                            .padding()
                        
                        Text("Rest Day")
                            .font(.title)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    // Regular Practice View
                    ScrollView {
                        VStack(spacing: 16) {
                            // Practice Summary section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Practice Summary")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.horizontal)
                                
                                TextField("Enter practice summary...", text: $summary)
                                    .textFieldStyle(.roundedBorder)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(showingSummaryError ? .red : .clear, lineWidth: 2)
                                    )
                                    .onChange(of: summary) { _, _ in
                                        showingSummaryError = false
                                    }
                                
                                if showingSummaryError {
                                    Text("Please enter a practice summary")
                                        .font(.caption)
                                        .foregroundStyle(.red)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                            )
                            .padding(.horizontal)
                            
                            // Practice Blocks
                            VStack(alignment: .leading, spacing: 8) {
                                LazyVGrid(columns: [
                                    GridItem(.flexible(), spacing: 12),
                                    GridItem(.flexible(), spacing: 12)
                                ], spacing: 12) {
                                    ForEach($blocks) { $block in
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                TextField("Block Title", text: $block.title)
                                                    .font(.subheadline)
                                                    .textFieldStyle(.plain)
                                                    .foregroundStyle(.secondary)
                                                    .padding(.vertical, 6)
                                                    .padding(.horizontal, 12)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 8)
                                                            .fill(Color(.systemGray6))
                                                    )
                                                
                                                Menu {
                                                    Button(action: {
                                                        viewModel.saveBlock(block)
                                                    }) {
                                                        Label("Save Block", systemImage: "square.and.arrow.down")
                                                    }
                                                    
                                                    Button(action: {
                                                        selectedBlockId = block.id
                                                        showingBlockSearch = true
                                                    }) {
                                                        Label("Search Blocks", systemImage: "magnifyingglass")
                                                    }
                                                    
                                                    Button(action: {
                                                        if let index = blocks.firstIndex(where: { $0.id == block.id }) {
                                                            blocks.insert(PracticeBlock(), at: index + 1)
                                                        }
                                                    }) {
                                                        Label("Insert Block", systemImage: "plus.rectangle.on.rectangle")
                                                    }
                                                    
                                                    Button(role: .destructive) {
                                                        blocks.removeAll { $0.id == block.id }
                                                        if blocks.isEmpty {
                                                            blocks.append(PracticeBlock())
                                                        }
                                                    } label: {
                                                        Label("Delete Block", systemImage: "trash")
                                                    }
                                                } label: {
                                                    Image(systemName: "ellipsis.circle")
                                                        .font(.title3)
                                                        .foregroundStyle(.secondary)
                                                }
                                            }
                                            .padding(.horizontal, 8)
                                            
                                            TextEditor(text: $block.content)
                                                .frame(height: 100)
                                                .padding(6)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(Color.black.opacity(0.05))
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                                )
                                                .padding(.horizontal, 8)
                                        }
                                        .padding(.vertical, 4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(.systemBackground))
                                                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
                                        )
                                    }
                                }
                                .padding(.horizontal, 8)
                                
                                // Add Block Button
                                Button(action: {
                                    blocks.append(PracticeBlock())
                                }) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Add Block")
                                    }
                                    .foregroundStyle(.blue)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                    )
                                }
                                .padding(.horizontal)
                            }
                            
                            // Live Time Selector
                            VStack(spacing: 16) {
                                HStack {
                                    Text("Live Minutes")
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    Picker("", selection: $liveTimeMinutes) {
                                        ForEach(0...60, id: \.self) { minutes in
                                            Text(minutes == 0 ? "None" : "\(minutes) min")
                                                .tag(minutes)
                                                .frame(maxWidth: .infinity, alignment: .trailing)
                                        }
                                    }
                                    .frame(width: 100)
                                    .tint(.gray)
                                    .labelsHidden()
                                }
                                .padding(.horizontal)
                                
                                // Lift Toggle
                                Toggle(isOn: $includesLift) {
                                    Text("Lift")
                                        .font(.headline)
                                }
                                .padding(.horizontal)
                                .tint(.orange)
                            }
                            .padding(.vertical, 8)
                            
                            // Intensity slider section with save button
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Practice Intensity")
                                        .font(.headline)
                                    Spacer()
                                    Text("\(Int(intensity * 10))/10")
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                }
                                
                                HStack(spacing: 12) {
                                    Text("1")
                                        .font(.subheadline)
                                        .foregroundStyle(.blue)
                                    
                                    Slider(value: $intensity, in: 0...1, step: 0.1) { _ in
                                        // Round to nearest 0.1 after sliding
                                        intensity = round(intensity * 10) / 10
                                    }
                                    .tint(
                                        Color(
                                            hue: max(0, min(0.3, 0.3 - (intensity * 0.3))),  // Goes from green (0.3) to red (0.0)
                                            saturation: 0.7,
                                            brightness: 0.7
                                        )
                                    )
                                    
                                    Text("10")
                                        .font(.subheadline)
                                        .foregroundStyle(.green)
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            
                            // Save button
                            Button("Save Practice") {
                                if summary.isEmpty {
                                    showingSummaryError = true
                                } else {
                                    savePractice()
                                }
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
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") { 
                        dismiss() 
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text(editingPractice == nil ? "New Practice" : "Edit Practice")
                        .font(.system(.title3, design: .rounded, weight: .heavy))
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
                
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            showingRecurrenceOptions = true
                        } label: {
                            Label("Repeat", systemImage: "repeat")
                        }
                        
                        Button {
                            showingSaveTemplate = true
                        } label: {
                            Label("Save as Template", systemImage: "doc.badge.plus")
                        }
                        
                        if editingPractice != nil {
                            Button(role: .destructive) {
                                isDeleting = true
                                viewModel.deletePractice(for: date)
                                onSave()
                                dismiss()
                            } label: {
                                Label("Delete Practice", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.blue)
                            .shadow(color: .blue.opacity(0.3), radius: 4)
                    }
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
            .alert("Save as Template", isPresented: $showingSaveTemplate) {
                TextField("Template Name", text: $templateName)
                Button("Cancel", role: .cancel) { }
                Button("Save") {
                    if !templateName.isEmpty {
                        viewModel.saveTemplate(
                            name: templateName,
                            sections: sections,
                            intensity: intensity,
                            liveTimeMinutes: liveTimeMinutes,
                            includesLift: includesLift,
                            practiceTime: practiceTime
                        )
                        templateName = ""
                        showingSaveTemplate = false
                    }
                }
                .disabled(templateName.isEmpty)
            } message: {
                Text("Enter a name for this practice template")
            }
            .sheet(isPresented: $showingRecurrenceOptions) {
                NavigationStack {
                    Form {
                        Section {
                            Picker("Repeat", selection: $recurrencePattern) {
                                ForEach(RecurrencePattern.allCases, id: \.self) { pattern in
                                    Text(pattern.rawValue).tag(pattern)
                                }
                            }
                            .pickerStyle(.inline)
                        }
                        
                        if recurrencePattern != .none {
                            Section {
                                DatePicker(
                                    "Until",
                                    selection: $recurrenceEndDate,
                                    in: date...,
                                    displayedComponents: .date
                                )
                            }
                        }
                    }
                    .navigationTitle("Repeat Practice")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showingRecurrenceOptions = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                showingRecurrenceOptions = false
                            }
                        }
                    }
                }
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $showingBlockSearch) {
                BlockSearchView(viewModel: viewModel) { selectedBlock in
                    if let selectedBlockId = selectedBlockId,
                       let index = blocks.firstIndex(where: { $0.id == selectedBlockId }) {
                        blocks[index] = selectedBlock
                    }
                }
            }
        }
        .presentationDetents([.large])
        .interactiveDismissDisabled(false)
        .onDisappear {
            if !summary.isEmpty && !isDeleting {
                savePractice()
                onSave()
            }
        }
        .onChange(of: presentationMode.wrappedValue.isPresented) { oldValue, newValue in
            if !newValue && !isDismissing {
                isDismissing = true
                if !summary.isEmpty && !isDeleting {
                    savePractice()
                    onSave()
                }
            }
        }
    }
    
    private func saveRecurringPractices() {
        var currentDate = date
        while let nextDate = recurrencePattern.nextDate(from: currentDate),
              nextDate <= recurrenceEndDate {
            let practice = Practice(
                date: nextDate,
                type: practiceType,
                sections: sections,
                intensity: intensity,
                isFromTemplate: false
            )
            viewModel.savePractice(practice)
            currentDate = nextDate
        }
    }
    
    private func savePractice() {
        // Convert blocks to sections
        var allSections = [String]()
        
        // Add summary as first section
        if !summary.isEmpty {
            allSections.append(summary)
        }
        
        // Add blocks - modified to include blocks with only titles
        let blockSections = blocks.compactMap { block -> String? in
            if block.title.isEmpty && block.content.isEmpty { return nil }
            return block.title.isEmpty ? block.content : "\(block.title): \(block.content)"
        }
        allSections.append(contentsOf: blockSections)
        
        // Combine date and time components
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: practiceTime)
        let combinedDate = calendar.date(from: DateComponents(
            year: dateComponents.year,
            month: dateComponents.month,
            day: dateComponents.day,
            hour: timeComponents.hour,
            minute: timeComponents.minute
        )) ?? date
        
        let practice = Practice(
            id: editingPractice?.id ?? UUID(),
            date: combinedDate,
            type: practiceType,
            sections: allSections,
            intensity: practiceType == .rest ? 0.0 : intensity,
            isFromTemplate: editingPractice?.isFromTemplate ?? false,
            includesLift: includesLift,
            liveTimeMinutes: liveTimeMinutes
        )
        
        // Save the practice
        viewModel.savePractice(practice)
        
        // Handle recurring practices if needed
        if recurrencePattern != .none {
            saveRecurringPractices()
        }
        
        // Call onSave callback
        onSave()
        
        // Dismiss the view
        dismiss()
    }
    
    private func textEditorHeight(for text: String) -> CGFloat {
        let baseHeight: CGFloat = 40  // Minimum height
        let lineHeight: CGFloat = 20  // Approximate height per line
        let numberOfLines = text.components(separatedBy: .newlines).count
        return max(baseHeight, CGFloat(numberOfLines) * lineHeight)
    }
}

struct PracticeSectionField: View {
    @Binding var text: String
    
    var body: some View {
        TextField("Enter practice section...", text: $text, axis: .vertical)
            .textFieldStyle(.roundedBorder)
            .lineLimit(3...6)
    }
}

#Preview {
    NavigationStack {
        PracticeEntryView(date: Date(), viewModel: PracticeViewModel())
    }
} 
