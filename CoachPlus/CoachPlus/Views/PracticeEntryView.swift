import SwiftUI

//testing out a comment

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
    @State private var showingTemplateSavedMessage = false
    @State private var isFromTemplate: Bool
    @State private var exportURL: URL?
    @State private var showingShareSheet = false
    @State private var isExporting = false
    
    init(
        date: Date,
        viewModel: PracticeViewModel,
        editingPractice: Practice? = nil,
        practiceType: PracticeType = .practice,
        onSave: @escaping () -> Void = {}
    ) {
        self.date = date
        self.viewModel = viewModel
        self.editingPractice = editingPractice
        self.practiceType = practiceType
        self.onSave = onSave
        
        _practiceTime = State(initialValue: editingPractice?.date ?? viewModel.defaultPracticeTime)
        
        if let practice = editingPractice {
            _summary = State(initialValue: practice.sections.first ?? "")
        }
        
        _sections = State(initialValue: editingPractice?.sections ?? practiceType.defaultSections)
        _intensity = State(initialValue: editingPractice?.intensity ?? 0.5)
        _includesLift = State(initialValue: editingPractice?.includesLift ?? false)
        _liveTimeMinutes = State(initialValue: editingPractice?.liveTimeMinutes ?? 0)
        
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
        
        _isFromTemplate = State(initialValue: editingPractice?.isFromTemplate ?? false)
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if case .loading = viewModel.state {
                    ProgressView("Saving...")
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                }
                
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
                    ScrollView {
                        VStack(spacing: 16) {
                            SummaryField(
                                text: $summary,
                                showError: $showingSummaryError,
                                title: "Practice Summary",
                                placeholder: "Enter practice summary..."
                            )
                            
                            BlockEditorGrid(
                                blocks: $blocks,
                                selectedBlockId: $selectedBlockId,
                                showingBlockSearch: $showingBlockSearch,
                                viewModel: viewModel
                            )
                            
                            PracticeSettings(
                                liveTimeMinutes: $liveTimeMinutes,
                                includesLift: $includesLift
                            )
                            
                            IntensitySlider(
                                intensity: $intensity,
                                title: "Practice Intensity",
                                style: .intensity
                            )
                            
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
            .standardToolbar(
                title: editingPractice == nil ? "New Practice" : "Edit Practice",
                trailing: ToolbarItem(placement: .primaryAction) {
                    AnyView(
                    Menu {
                        Button(action: {
                            // Create practice object from current state
                            let blockSections = blocks
                                .filter { !$0.isEmpty }
                                .map { $0.formattedForPractice() }
                            
                            let sections = [summary] + blockSections
                            
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
                                sections: sections,
                                intensity: intensity,
                                isFromTemplate: false,
                                includesLift: includesLift,
                                liveTimeMinutes: liveTimeMinutes
                            )
                            
                            // Export to PDF
                            isExporting = true
                            do {
                                print("Starting PDF export...")
                                let pdfDocument = try PracticeExporter.generatePDF(for: practice)
                                print("PDF generated successfully")
                                let fileURL = try PracticeExporter.savePDF(pdfDocument, for: practice)
                                print("PDF saved to: \(fileURL)")
                                
                                exportURL = fileURL
                                showingShareSheet = true
                            } catch {
                                print("PDF Export Error: \(error)")
                                viewModel.handleError(error)
                            }
                            isExporting = false
                        }) {
                            Label("Export PDF", systemImage: "doc.text")
                        }
                        .disabled(isExporting)
                        
                        Button {
                            showingRecurrenceOptions = true
                        } label: {
                            Label("Repeat", systemImage: "repeat")
                        }
                        
                        Button {
                            showingSaveTemplate = true
                        } label: {
                            Label("Save as Template", systemImage: "square.and.arrow.down")
                        }
                        
                        if editingPractice != nil {
                            Button(role: .destructive) {
                                isDeleting = true
                                viewModel.deletePractice(for: date)
                                onSave()
                                dismissToRoot()
                            } label: {
                                Label("Delete Practice", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.blue)
                            .shadow(color: .blue.opacity(0.3), radius: 4)
                    }
                    )
                }
            )
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
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportURL {
                    ShareSheet(activityItems: [url])
                        .presentationDetents([.medium, .large])
                        .edgesIgnoringSafeArea(.bottom)
                }
            }
            .overlay(alignment: .top) {
                if showingTemplateSavedMessage {
                    Text("Template Saved!")
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(.green)
                                .shadow(radius: 4)
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(1)
                        .padding(.top, 8)
                }
            }
            .animation(.spring(duration: 0.5), value: showingTemplateSavedMessage)
            .alert("Save as Template", isPresented: $showingSaveTemplate) {
                TextField("Template Name", text: $templateName)
                Button("Save", action: saveAsTemplate)
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Enter a name for this template")
            }
            .overlay {
                if case .error(let error) = viewModel.state {
                    Text(error.localizedDescription)
                        .foregroundStyle(.white)
                        .padding()
                        .background(.red.opacity(0.8))
                        .cornerRadius(10)
                        .padding()
                }
            }
            .animation(.spring(duration: 0.5), value: viewModel.state)
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
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: nextDate)
            let timeComponents = calendar.dateComponents([.hour, .minute], from: practiceTime)
            let combinedDate = calendar.date(from: DateComponents(
                year: dateComponents.year,
                month: dateComponents.month,
                day: dateComponents.day,
                hour: timeComponents.hour,
                minute: timeComponents.minute
            )) ?? nextDate
            
            let blockSections = blocks
                .filter { !$0.isEmpty }
                .map { $0.formattedForPractice() }
            
            let sections = [summary] + blockSections
            
            let practice = Practice(
                date: combinedDate,
                type: practiceType,
                sections: sections,
                intensity: intensity,
                isFromTemplate: false,
                includesLift: includesLift,
                liveTimeMinutes: liveTimeMinutes
            )
            viewModel.savePractice(practice)
            currentDate = nextDate
        }
    }
    
    private func savePractice() {
        if isDismissing || isDeleting { return }
        
        let blockSections = blocks
            .filter { !$0.isEmpty }
            .map { $0.formattedForPractice() }
        
        let sections = [summary] + blockSections
        
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
            sections: sections,
            intensity: intensity,
            isFromTemplate: false,
            includesLift: includesLift,
            liveTimeMinutes: liveTimeMinutes
        )
        
        viewModel.savePractice(practice)
        
        if recurrencePattern != .none {
            saveRecurringPractices()
        }
        
        isDismissing = true
        onSave()
        dismissToRoot()
    }
    
    private func textEditorHeight(for text: String) -> CGFloat {
        let baseHeight: CGFloat = 40  // Minimum height
        let lineHeight: CGFloat = 20  // Approximate height per line
        let numberOfLines = text.components(separatedBy: .newlines).count
        return max(baseHeight, CGFloat(numberOfLines) * lineHeight)
    }
    
    private func saveAsTemplate() {
        print("📝 Attempting to save template: \(templateName)")
        
        let blockSections = blocks
            .filter { !$0.isEmpty }
            .map { $0.formattedForPractice() }
        
        let sections = [summary] + blockSections
        print("📝 Template sections: \(sections)")
        
        viewModel.saveTemplate(
            name: templateName,
            sections: sections,
            intensity: intensity,
            liveTimeMinutes: liveTimeMinutes,
            includesLift: includesLift,
            practiceTime: practiceTime
        )
        
        print("📝 Template saved!")
        showingSaveTemplate = false
        showingTemplateSavedMessage = true
    }
    
    func dismissToRoot() {
        DispatchQueue.main.async {
            dismiss()
            NotificationCenter.default.post(name: NSNotification.Name.dismissAddPracticeView, object: nil)
        }
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

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        // Handle iPad presentation
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                controller.popoverPresentationController?.sourceView = window
                controller.popoverPresentationController?.permittedArrowDirections = []
                controller.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 0, height: 0)
            }
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        PracticeEntryView(date: Date(), viewModel: PracticeViewModel())
    }
} 
