import SwiftUI

struct AddSectionView: View {
    @Binding var sections: [String]
    @Environment(\.dismiss) private var dismiss
    @State private var newSection: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Block Title", text: $newSection)
                }
            }
            .navigationTitle("Add Block")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if !newSection.isEmpty {
                            sections.append(newSection)
                            dismiss()
                        }
                    }
                    .disabled(newSection.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddSectionView(sections: .constant([]))
} 