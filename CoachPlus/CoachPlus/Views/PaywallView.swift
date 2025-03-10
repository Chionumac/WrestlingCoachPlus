import SwiftUI

struct PaywallView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("Continue Using Coach+")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)
                Text("Your free trial has ended")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 40)
            
            // Features
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(icon: "checkmark.circle.fill", text: "Keep tracking your practices")
                FeatureRow(icon: "checkmark.circle.fill", text: "Maintain your performance data")
                FeatureRow(icon: "checkmark.circle.fill", text: "Continue analyzing progress")
                FeatureRow(icon: "checkmark.circle.fill", text: "Access your coaching history")
            }
            .padding(.vertical, 30)
            
            Spacer()
            
            // Subscription Button
            if let product = subscriptionManager.products.first {
                VStack(spacing: 8) {
                    Button {
                        Task {
                            try? await subscriptionManager.purchase()
                            dismiss()
                        }
                    } label: {
                        Text("Subscribe for \(product.displayPrice)/month")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    
                    Text("Continue using all features for \(product.displayPrice)/month")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Terms and Privacy
            HStack(spacing: 4) {
                Link("Terms of Service", destination: URL(string: "https://your-terms-url.com")!)
                Text("•")
                Link("Privacy Policy", destination: URL(string: "https://your-privacy-url.com")!)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.bottom, 20)
        }
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
            Text(text)
                .font(.body)
        }
    }
}

#Preview {
    PaywallView()
} 
