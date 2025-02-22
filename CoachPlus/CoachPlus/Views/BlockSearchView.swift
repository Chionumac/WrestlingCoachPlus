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
                    BlockListItem(
                        block: block,
                        onSelect: {
                            onSelect(block)
                            dismiss()
                        },
                        onDelete: {
                            if let index = viewModel.savedBlocks.firstIndex(where: { $0.id == block.id }) {
                                viewModel.savedBlocks.remove(at: index)
                            }
                        }
                    )
                }
            }
            .formSectionStyle()
            .searchable(text: $searchText, prompt: "Search blocks")
            .navigationTitle("Saved Blocks")
            .navigationBarTitleDisplayMode(.inline)
            .standardToolbar(title: "Saved Blocks")
        }
    }
} 