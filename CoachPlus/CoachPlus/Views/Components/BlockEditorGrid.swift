import SwiftUI

struct BlockEditorGrid: View {
    @Binding var blocks: [PracticeBlock]
    @Binding var selectedBlockId: UUID?
    @Binding var showingBlockSearch: Bool
    let viewModel: PracticeViewModel
    
    var body: some View {
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
                                    if block.isValid {
                                        viewModel.saveBlock(block)
                                    }
                                }) {
                                    Label("Save Block", systemImage: "square.and.arrow.down")
                                }
                                .disabled(!block.isValid)
                                
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
    }
}

#Preview {
    BlockEditorGrid(
        blocks: .constant([PracticeBlock()]),
        selectedBlockId: .constant(nil),
        showingBlockSearch: .constant(false),
        viewModel: PracticeViewModel()
    )
    .padding()
} 