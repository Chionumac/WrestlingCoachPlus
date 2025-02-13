import Foundation

class BlockManager: ObservableObject {
    @Published var blocks: [PracticeBlock]
    let viewModel: PracticeViewModel
    
    init(blocks: [PracticeBlock] = [], viewModel: PracticeViewModel) {
        self.blocks = blocks
        self.viewModel = viewModel
    }
    
    func insertBlock(_ block: PracticeBlock, at index: Int? = nil) {
        // Create a new block with copied content but new ID
        let newBlock = PracticeBlock(
            id: UUID(),  // Always create new ID
            title: block.title,
            content: block.content
        )
        
        if let index = index {
            blocks.insert(newBlock, at: index)
        } else {
            blocks.append(newBlock)
        }
    }
    
    func removeBlock(at index: Int) {
        blocks.remove(at: index)
    }
    
    func removeBlock(withId id: UUID) {
        blocks.removeAll { $0.id == id }
    }
    
    func saveBlock(_ block: PracticeBlock) {
        viewModel.saveBlock(block)
    }
} 