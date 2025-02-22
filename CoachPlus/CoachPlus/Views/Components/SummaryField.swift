import SwiftUI

struct SummaryField: View {
    @Binding var text: String
    @Binding var showError: Bool
    let title: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(showError ? .red : .clear, lineWidth: 2)
                )
                .onChange(of: text) { _, _ in
                    showError = false
                }
            
            if showError {
                Text("Please enter a practice summary")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        )
        .padding(.horizontal)
    }
}

#Preview {
    VStack {
        SummaryField(
            text: .constant(""),
            showError: .constant(false),
            title: "Practice Summary",
            placeholder: "Enter practice summary..."
        )
        
        SummaryField(
            text: .constant(""),
            showError: .constant(true),
            title: "Practice Summary",
            placeholder: "Enter practice summary..."
        )
    }
    .padding()
} 