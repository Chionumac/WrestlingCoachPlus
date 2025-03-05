import SwiftUI

struct WelcomeView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    var body: some View {
        VStack(spacing: 24) {
            // App Icon and Title
            VStack(spacing: 16) {
                Image("Coach Icon") // Make sure to have this in your assets
                    .resizable()
                    .frame(width: 100, height: 100)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                
                Text("Welcome to Wrestling Coach Plus")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            // Features List
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(icon: "checkmark.circle.fill", text: "Track all your practices and competitions")
                FeatureRow(icon: "checkmark.circle.fill", text: "Performance analytics and insights")
                FeatureRow(icon: "checkmark.circle.fill", text: "Video and results tracking")
                FeatureRow(icon: "checkmark.circle.fill", text: "Comprehensive coaching tools")
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Trial Info
            VStack(spacing: 8) {
                Text("Try Wrestling Coach Plus Free")
                    .font(.title2.bold())
                
                Text("14-day free trial to experience the full app.\nThen just $1.99/month to continue.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .padding()
            
            // Start Button
            Button {
                subscriptionManager.startTrialIfNeeded()
                dismiss()
            } label: {
                Text("Start 14-Day Free Trial")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            // Terms
            Group {
                Text("By continuing, you agree to our ")
                + Text("Terms of Service").foregroundColor(.blue)
                + Text(" and ")
                + Text("Privacy Policy").foregroundColor(.blue)
            }
            .font(.caption)
            .multilineTextAlignment(.center)
            .padding(.bottom, 30)
        }
        .padding()
    }
}

#Preview {
    WelcomeView()
} 