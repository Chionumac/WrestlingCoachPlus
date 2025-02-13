import SwiftUI

struct PracticeBlockListView: View {
    @StateObject private var blockManager: BlockManager
    @Binding var showingBlockSearch: Bool
    @Binding var selectedBlockId: UUID?
    @Binding var isDeleting: Bool
    
    init(blocks: [PracticeBlock], viewModel: PracticeViewModel, showingBlockSearch: Binding<Bool>, selectedBlockId: Binding<UUID?>, isDeleting: Binding<Bool>) {
        _blockManager = StateObject(wrappedValue: BlockManager(blocks: blocks, viewModel: viewModel))
        _showingBlockSearch = showingBlockSearch
        _selectedBlockId = selectedBlockId
        _isDeleting = isDeleting
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Practice Blocks")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button(action: { showingBlockSearch = true }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.blue)
                }
            }
            .padding(.horizontal)
            
            // Blocks List
            ForEach(blockManager.blocks) { block in
                PracticeBlockRow(
                    block: block,
                    isSelected: selectedBlockId == block.id,
                    onTap: {
                        withAnimation {
                            if selectedBlockId == block.id {
                                selectedBlockId = nil
                            } else {
                                selectedBlockId = block.id
                            }
                        }
                    },
                    onSave: { blockManager.saveBlock(block) },
                    onDelete: {
                        withAnimation {
                            isDeleting = true
                            blockManager.removeBlock(withId: block.id)
                            isDeleting = false
                        }
                    }
                )
            }
            
            // Add Block Button
            Button(action: {
                withAnimation {
                    blockManager.insertBlock(PracticeBlock())
                }
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Block")
                }
                .foregroundStyle(.blue)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.blue.opacity(0.3), lineWidth: 1)
                )
            }
            .padding(.horizontal)
        }
    }
}

// Updated Block Row View
struct PracticeBlockRow: View {
    let block: PracticeBlock
    let isSelected: Bool
    let onTap: () -> Void
    let onSave: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                TextField("Block Title (optional)", text: .constant(block.title))
                    .font(.headline)
                
                Spacer()
                
                Button(action: onSave) {
                    Image(systemName: "square.and.arrow.down")
                        .foregroundStyle(.blue)
                }
            }
            
            TextField("Block Content", text: .constant(block.content), axis: .vertical)
                .lineLimit(3...6)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: isSelected ? .blue.opacity(0.3) : .black.opacity(0.1),
                       radius: isSelected ? 6 : 4,
                       y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? .blue : .clear, lineWidth: 2)
        )
        .padding(.horizontal)
        .onTapGesture(perform: onTap)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    PracticeBlockListView(
        blocks: [PracticeBlock()],
        viewModel: PracticeViewModel(),
        showingBlockSearch: .constant(false),
        selectedBlockId: .constant(nil),
        isDeleting: .constant(false)
    )
} 