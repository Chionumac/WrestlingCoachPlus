import SwiftUI

// Move PracticeOption enum outside of AddPracticeView
enum PracticeOption: String, CaseIterable {
    case scratch = "Add Practice"
    case template = "Select Template"
    case competition = "Add Competition"
    case rest = "Add Rest Day"
    
    var icon: String {
        switch self {
        case .scratch: return "plus.circle.fill"
        case .template: return "doc.fill"
        case .competition: return "trophy.fill"
        case .rest: return "moon.zzz.fill"
        }
    }
    
    var color: Color {
        Color(.systemGreen)
    }
}

struct AddPracticeView: View {
    let date: Date
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: PracticeViewModel
    let onSave: () -> Void
    @State private var showingTemplates = false
    @State private var showingImagePicker = false
    @State private var backgroundImage: UIImage?
    @AppStorage("practiceViewBackground") private var savedImageData: Data?
    @State private var showingPracticeEntry = false
    @State private var showingCompetition = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Background Image with Gradient Overlay
                    if let backgroundImage {
                        Image(uiImage: backgroundImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                            .overlay {
                                // Leave space for the header
                                VStack(spacing: 0) {
                                    // Clear area for header
                                    Color.clear
                                        .frame(height: 0)
                                    
                                    // Gradient overlay for the rest
                                    LinearGradient(
                                        colors: [
                                            .blue.opacity(0.7),
                                            .green.opacity(0.7)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                }
                            }
                    }
                    
                    // Main Content
                    VStack(spacing: 20) {
                        Spacer()
                        
                        // 2x2 Grid of buttons
                        VStack(spacing: 16) {
                            // First row
                            HStack(spacing: 16) {
                                // Regular Practice Button
                                Button {
                                    showingPracticeEntry = true
                                } label: {
                                    PracticeOptionButton(
                                        icon: "figure.run",
                                        title: "Practice",
                                        color: .green
                                    )
                                }
                                .sheet(isPresented: $showingPracticeEntry) {
                                    PracticeEntryView(
                                        date: date,
                                        viewModel: viewModel,
                                        onSave: onSave
                                    )
                                }
                                
                                // Template Button
                                Button(action: { showingTemplates = true }) {
                                    PracticeOptionButton(
                                        icon: "doc.fill",
                                        title: "Template",
                                        color: .blue
                                    )
                                }
                            }
                            
                            // Second row
                            HStack(spacing: 16) {
                                // Competition Button
                                Button {
                                    showingCompetition = true
                                } label: {
                                    PracticeOptionButton(
                                        icon: "trophy.fill",
                                        title: "Competition",
                                        color: .orange
                                    )
                                }
                                .sheet(isPresented: $showingCompetition) {
                                    AddCompetitionView(
                                        date: date,
                                        viewModel: viewModel,
                                        onSave: onSave
                                    )
                                }
                                
                                // Rest Day Button
                                Button(action: {
                                    let practice = Practice(
                                        date: date,
                                        type: .rest,
                                        sections: PracticeType.rest.defaultSections,
                                        intensity: 0.0,
                                        isFromTemplate: false
                                    )
                                    viewModel.savePractice(practice)
                                    onSave()
                                    dismissToRoot()
                                }) {
                                    PracticeOptionButton(
                                        icon: "moon.zzz.fill",
                                        title: "Rest Day",
                                        color: .purple
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle(dateFormatter.string(from: date))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") { dismiss() }
                }
                
                ToolbarItem(placement: .principal) {
                    Text(dateFormatter.string(from: date))
                        .font(.system(.title3, design: .rounded, weight: .heavy))
                        .tracking(4)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .green.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingImagePicker = true }) {
                        Image(systemName: "photo")
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .green.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $backgroundImage) { success in
                    if success, let image = backgroundImage {
                        if let imageData = image.jpegData(compressionQuality: 0.7) {
                            savedImageData = imageData
                        }
                    }
                }
            }
            .onAppear {
                if let imageData = savedImageData,
                   let savedImage = UIImage(data: imageData) {
                    backgroundImage = savedImage
                }
            }
            .sheet(isPresented: $showingTemplates) {
                PracticeTemplateView(
                    viewModel: viewModel.templateViewModel,
                    date: date,
                    onSelect: { template in
                        let practice = Practice(
                            date: date,
                            type: .practice,
                            sections: template.sections,
                            intensity: template.intensity,
                            isFromTemplate: true,
                            includesLift: template.includesLift,
                            liveTimeMinutes: template.liveTimeMinutes
                        )
                        viewModel.savePractice(practice)
                        onSave()
                        dismissToRoot()
                    }
                )
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name.dismissAddPracticeView)) { _ in
            dismiss()
        }
    }
    
    func dismissToRoot() {
        // Dismiss both views simultaneously
        DispatchQueue.main.async {
            dismiss()
            NotificationCenter.default.post(name: NSNotification.Name.dismissAddPracticeView, object: nil)
        }
    }
}

struct PracticeOptionButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .green.opacity(0.7)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: color.opacity(0.3), radius: 4)
            
            Text(title.uppercased())
                .font(.system(.subheadline, design: .rounded, weight: .heavy))
                .tracking(2)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .green.opacity(0.7)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        )
    }
}

struct TemplateListView: View {
    let date: Date
    @ObservedObject var viewModel: PracticeViewModel
    let onSelect: (PracticeTemplate) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(viewModel.templates) { template in
                Button(action: { onSelect(template) }) {
                    VStack(alignment: .leading) {
                        Text(template.name)
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text("\(template.sections.count) blocks")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Templates")
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
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") { dismiss() }
                }
            }
        }
    }
}

// Separate view for the grid of options
struct PracticeOptionsGrid: View {
    @Binding var selectedOption: PracticeOption?
    @Binding var showingPracticeEntry: Bool
    @Binding var showingTemplates: Bool
    
    var body: some View {
        GeometryReader { geometry in
            let spacing: CGFloat = 16
            let itemSize = (geometry.size.width - (spacing * 3) - 32) / 2
            
            VStack(spacing: spacing) {
                // First row
                HStack(spacing: spacing) {
                    OptionButton(
                        option: .scratch,
                        size: itemSize,
                        action: {
                            selectedOption = .scratch
                            showingPracticeEntry = true
                        }
                    )
                    
                    OptionButton(
                        option: .template,
                        size: itemSize,
                        action: { 
                            selectedOption = .template
                            showingTemplates = true 
                        }
                    )
                }
                
                // Second row
                HStack(spacing: spacing) {
                    OptionButton(
                        option: .competition,
                        size: itemSize,
                        action: {
                            selectedOption = .competition
                            showingPracticeEntry = true
                        }
                    )
                    
                    OptionButton(
                        option: .rest,
                        size: itemSize,
                        action: { 
                            selectedOption = .rest
                            showingPracticeEntry = true 
                        }
                    )
                }
            }
            .frame(maxHeight: .infinity, alignment: .center)
            .padding()
        }
    }
}

// Separate view for each option button
struct OptionButton: View {
    let option: PracticeOption
    let size: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: option.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(option.color)
                
                Text(option.rawValue)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
            }
            .frame(width: size, height: size * 0.8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
    }
}

// Add ImagePicker struct
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let onImagePicked: (Bool) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
                parent.onImagePicked(true)
            } else {
                parent.onImagePicked(false)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onImagePicked(false)
            parent.dismiss()
        }
    }
}

#Preview {
    AddPracticeView(date: Date(), viewModel: PracticeViewModel()) {
        // Placeholder for the onSave closure
    }
} 
