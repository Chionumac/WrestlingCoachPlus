import SwiftUI

struct BlockListItem: View {
    let block: PracticeBlock
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(block.displayTitle)
                .font(.headline)
            Text(block.content)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .opacity(block.isEmpty ? 0.5 : 1.0)
        .contentShape(Rectangle())
        .onTapGesture(perform: onSelect)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    List {
        BlockListItem(
            block: PracticeBlock(title: "Test Block", content: "Test Content"),
            onSelect: {},
            onDelete: {}
        )
    }
} 