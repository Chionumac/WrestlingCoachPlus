import SwiftUI

struct DeleteConfirmationAlert: ViewModifier {
    let title: String
    let message: String
    @Binding var isPresented: Bool
    let onDelete: () -> Void
    
    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: $isPresented) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    onDelete()
                }
            } message: {
                Text(message)
            }
    }
}

extension View {
    func deleteConfirmation(
        title: String = "Delete",
        message: String,
        isPresented: Binding<Bool>,
        onDelete: @escaping () -> Void
    ) -> some View {
        modifier(DeleteConfirmationAlert(
            title: title,
            message: message,
            isPresented: isPresented,
            onDelete: onDelete
        ))
    }
}

#Preview {
    Text("Test")
        .deleteConfirmation(
            title: "Delete Item",
            message: "Are you sure you want to delete this item? This action cannot be undone.",
            isPresented: .constant(true)
        ) {
            print("Delete tapped")
        }
} 