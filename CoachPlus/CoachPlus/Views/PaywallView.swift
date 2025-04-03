import SwiftUI

struct PaywallView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingRestoreAlert = false
    @State private var restoreAlertMessage = ""
    
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
                        Text("Subscribe for \(product.displayPrice)/year")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    
                    Button {
                        Task {
                            let result = try? await subscriptionManager.restorePurchases()
                            switch result {
                            case .restored:
                                restoreAlertMessage = "Your purchases have been restored successfully!"
                                showingRestoreAlert = true
                                // Dismiss after successful restore
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    dismiss()
                                }
                            case .noPurchasesFound:
                                restoreAlertMessage = "No previous purchases were found to restore."
                                showingRestoreAlert = true
                            case .error:
                                restoreAlertMessage = "There was an error restoring your purchases. Please try again."
                                showingRestoreAlert = true
                            case .none:
                                restoreAlertMessage = "An unknown error occurred. Please try again."
                                showingRestoreAlert = true
                            }
                        }
                    } label: {
                        Text("Restore Purchases")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 8)
                    
                    Text("Continue using all features for \(product.displayPrice)/year")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Terms and Privacy
            HStack(spacing: 4) {
                Link("Terms of Service", destination: URL(string: "https://chionumac.github.io/wrestlingcoachplus-terms")!)
                Text("•")
                Link("Privacy Policy", destination: URL(string: "https://chionumac.github.io/wrestlingcoachplus-privacy/privacy-policy")!)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.bottom, 20)
        }
        .padding()
        .alert("Restore Purchases", isPresented: $showingRestoreAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(restoreAlertMessage)
        }
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
