import SwiftUI

struct WelcomeView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    var body: some View {
        VStack(spacing: 24) {
            // App Icon and Title
            VStack(spacing: 16) {
                Image("AppLogo") // Make sure to have this in your assets
                    .resizable()
                    .frame(width: 250, height: 75)
                    .shadow(radius: 10)
                
                Text("Welcome to Coach+")
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
                
                Text("14-day free trial to experience the full app.\nThen just $4.99/year to continue.")
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
            HStack(spacing: 4) {
                Text("By continuing, you agree to our")
                Link("Terms of Service", destination: URL(string: "https://chionumac.github.io/wrestlingcoachplus-terms")!)
                    .foregroundColor(.blue)
                Text("and")
                Link("Privacy Policy", destination: URL(string: "https://chionumac.github.io/wrestlingcoachplus-privacy/privacy-policy")!)
                    .foregroundColor(.blue)
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
