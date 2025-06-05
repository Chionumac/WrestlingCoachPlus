import SwiftUI

struct PaywallView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingRestoreAlert = false
    @State private var restoreAlertMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Continue Using Coach+")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            Text("Your free trial has ended")
                .font(.title3)
                .foregroundColor(.gray)
                .padding(.bottom, 16)
            VStack(alignment: .leading, spacing: 16) {
                Label("Keep tracking your practices", systemImage: "checkmark.circle.fill")
                Label("Maintain your performance data", systemImage: "checkmark.circle.fill")
                Label("Continue analyzing progress", systemImage: "checkmark.circle.fill")
                Label("Access your coaching history", systemImage: "checkmark.circle.fill")
            }
            .foregroundColor(.blue)
            .font(.body)
            .padding(.bottom, 32)
            
            // Subscribe Button
            Button(action: {
                Task {
                    do {
                        try await subscriptionManager.purchase()
                    } catch {
                        restoreAlertMessage = error.localizedDescription
                        showingRestoreAlert = true
                    }
                }
            }) {
                Text("Subscribe")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            // Restore Purchase Button
            Button(action: {
                Task {
                    do {
                        try await subscriptionManager.restorePurchases()
                        restoreAlertMessage = "Purchases restored!"
                    } catch {
                        restoreAlertMessage = error.localizedDescription
                    }
                    showingRestoreAlert = true
                }
            }) {
                Text("Restore Purchase")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            .padding(.bottom, 24)
            
            Spacer()
            HStack {
                Button("Terms of Service") {
                    // Open terms URL
                }
                .font(.footnote)
                .foregroundColor(.gray)
                Text("•")
                    .foregroundColor(.gray)
                Button("Privacy Policy") {
                    // Open privacy URL
                }
                .font(.footnote)
                .foregroundColor(.gray)
            }
            .padding(.bottom, 8)
        }
        .padding()
        .alert("Restore Purchases", isPresented: $showingRestoreAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(restoreAlertMessage)
        }
        .interactiveDismissDisabled(true)
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
