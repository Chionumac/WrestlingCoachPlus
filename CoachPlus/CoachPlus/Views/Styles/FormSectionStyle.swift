import SwiftUI

struct FormSectionStyle: ViewModifier {
    let spacing: CGFloat
    
    init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }
    
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 8)
            .listSectionSpacing(.compact)
    }
}

extension View {
    func formSectionStyle(spacing: CGFloat = 8) -> some View {
        modifier(FormSectionStyle(spacing: spacing))
    }
}

#Preview {
    NavigationStack {
        Form {
            Section {
                Text("Test Item 1")
                Text("Test Item 2")
            }
            .formSectionStyle()
        }
    }
} 