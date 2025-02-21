import SwiftUI

struct NavigationTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.subheadline, design: .rounded, weight: .heavy))
            .tracking(2)
            .foregroundStyle(
                LinearGradient(
                    colors: [.blue, .green.opacity(0.7)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }
}

extension View {
    func navigationTitleStyle() -> some View {
        modifier(NavigationTitleStyle())
    }
}

#Preview {
    NavigationStack {
        Color.clear
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Test Title")
                        .navigationTitleStyle()
                }
            }
    }
} 