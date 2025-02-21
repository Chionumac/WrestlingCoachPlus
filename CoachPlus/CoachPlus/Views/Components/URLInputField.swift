import SwiftUI

struct URLInputField: View {
    @Binding var urlString: String
    let placeholder: String
    let iconName: String
    let linkText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField(placeholder, text: $urlString)
            if let url = URL(string: urlString) {
                Link(destination: url) {
                    HStack {
                        Label(linkText, systemImage: "arrow.up.right")
                            .font(.subheadline)
                        Spacer()
                    }
                    .foregroundStyle(.blue)
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

#Preview {
    Form {
        URLInputField(
            urlString: .constant("https://example.com"),
            placeholder: "Results URL",
            iconName: "arrow.up.right",
            linkText: "Open Results"
        )
    }
} 