import SwiftUI

struct PracticeToolbarView: ToolbarContent {
    @Environment(\.dismiss) private var dismiss
    @Binding var showingSaveTemplate: Bool
    @Binding var showingRecurrenceOptions: Bool
    let onSave: () -> Void
    
    var body: some ToolbarContent {
        // Leading (Cancel)
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") {
                dismiss()
            }
        }
        
        // Title
        ToolbarItem(placement: .principal) {
            Text("New Practice")
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
        
        // Actions Menu
        ToolbarItem(placement: .primaryAction) {
            Menu {
                Button(action: { showingSaveTemplate = true }) {
                    Label("Save as Template", systemImage: "doc.fill")
                }
                
                Button(action: { showingRecurrenceOptions = true }) {
                    Label("Set Recurrence", systemImage: "repeat")
                }
                
                Button(action: onSave) {
                    Label("Save Practice", systemImage: "checkmark.circle.fill")
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