import SwiftUI

struct BlockSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: PracticeViewModel
    @State private var searchText = ""
    let onSelect: (PracticeBlock) -> Void
    
    var filteredBlocks: [PracticeBlock] {
        if searchText.isEmpty {
            return viewModel.savedBlocks
        } else {
            return viewModel.savedBlocks.filter { block in
                block.title.localizedCaseInsensitiveContains(searchText) ||
                block.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredBlocks) { block in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(block.title)
                            .font(.headline)
                        Text(block.content)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onSelect(block)
                        dismiss()
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            if let index = viewModel.savedBlocks.firstIndex(where: { $0.id == block.id }) {
                                viewModel.savedBlocks.remove(at: index)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search blocks")
            .navigationTitle("Saved Blocks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
} 