import SwiftUI

struct ViewToolbar: ToolbarContent {
    let title: String
    let isPresented: Bool
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode
    let trailing: ToolbarItem<Void, AnyView>?
    
    init(
        title: String,
        isPresented: Bool = true,
        trailing: ToolbarItem<Void, AnyView>? = nil
    ) {
        self.title = title
        self.isPresented = isPresented
        self.trailing = trailing
    }
    
    var body: some ToolbarContent {
        // Leading (Back/Cancel)
        ToolbarItem(placement: .navigationBarLeading) {
            if isPresented {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        
        // Title
        ToolbarItem(placement: .principal) {
            Text(title)
                .navigationTitleStyle()
        }
        
        // Keyboard dismiss
        ToolbarItem(placement: .keyboard) {
            Button(action: {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                             to: nil, from: nil, for: nil)
            }) {
                Image(systemName: "keyboard.chevron.compact.down")
                    .foregroundStyle(.blue)
            }
        }
        
        // Optional trailing item
        if let trailing = trailing {
            trailing
        }
    }
}

extension View {
    func standardToolbar(
        title: String,
        isPresented: Bool = true,
        trailing: ToolbarItem<Void, AnyView>? = nil
    ) -> some View {
        toolbar {
            ViewToolbar(title: title, isPresented: isPresented, trailing: trailing)
        }
    }
} 