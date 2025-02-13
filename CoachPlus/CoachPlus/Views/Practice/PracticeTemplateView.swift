import SwiftUI

struct PracticeTemplateView: View {
    @ObservedObject var viewModel: TemplateViewModel
    @Environment(\.dismiss) private var dismiss
    let date: Date
    let onSelect: (PracticeTemplate) -> Void
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.templates) { template in
                    Button(action: { onSelect(template) }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(template.name)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                
                                HStack(spacing: 12) {
                                    Text("\(template.sections.count) blocks")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    
                                    if template.liveTimeMinutes > 0 {
                                        HStack(spacing: 4) {
                                            Image(systemName: "timer")
                                                .font(.caption)
                                            Text("\(template.liveTimeMinutes)m")
                                        }
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    }
                                    
                                    if template.includesLift {
                                        Image(systemName: "dumbbell.fill")
                                            .font(.caption)
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(
                                                Capsule()
                                                    .fill(Color.black.opacity(0.8))
                                            )
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            // Intensity badge
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                                Text("\(Int(template.intensity * 10))/10")
                                    .font(.caption.bold())
                                    .foregroundStyle(.white)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.8))
                            )
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .swipeActions {
                        Button(role: .destructive) {
                            viewModel.deleteTemplate(template)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Practice Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
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
                }
            }
            .overlay {
                if viewModel.templates.isEmpty {
                    ContentUnavailableView(
                        "No Templates",
                        systemImage: "doc.fill",
                        description: Text("Save a practice as a template to see it here")
                    )
                }
            }
        }
    }
}

#Preview {
    PracticeTemplateView(
        viewModel: TemplateViewModel(),
        date: Date(),
        onSelect: { _ in }
    )
} 