import SwiftUI

struct GradientButtonStyle: ViewModifier {
    let isDisabled: Bool
    
    init(isDisabled: Bool = false) {
        self.isDisabled = isDisabled
    }
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [.blue, .green.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(isDisabled ? 0.5 : 1)
            )
            .foregroundStyle(.white)
            .font(.system(.subheadline, design: .rounded, weight: .bold))
            .tracking(1)
    }
}

extension View {
    func gradientButtonStyle(isDisabled: Bool = false) -> some View {
        modifier(GradientButtonStyle(isDisabled: isDisabled))
    }
}

#Preview {
    VStack(spacing: 20) {
        Button("Enabled Button") { }
            .gradientButtonStyle()
        
        Button("Disabled Button") { }
            .gradientButtonStyle(isDisabled: true)
            .disabled(true)
    }
    .padding()
} 