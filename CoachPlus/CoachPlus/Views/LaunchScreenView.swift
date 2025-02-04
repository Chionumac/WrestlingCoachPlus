import SwiftUI
import GoogleSignIn
import FirebaseAuth
import FirebaseCore

struct LaunchScreenView: View {
    @State private var isSignedIn = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        Group {
            if isSignedIn {
                ContentView()
            } else {
                VStack {
                    Spacer()
                    
                    Text("COACH+")
                        .font(.system(.largeTitle, design: .rounded, weight: .heavy))
                        .tracking(2)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .green.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Spacer()
                    
                    Button(action: signIn) {
                        HStack {
                            Image("google_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                            Text("Sign in with Google")
                                .font(.headline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                        )
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 50)
                }
                .background(Color(.systemGroupedBackground))
            }
        }
        .alert("Sign In Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            checkSignInStatus()
        }
    }
    
    private func checkSignInStatus() {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { _, error in
                if error == nil {
                    self.isSignedIn = true
                }
            }
        }
    }
    
    private func signIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                showingError = true
                errorMessage = error.localizedDescription
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                showingError = true
                errorMessage = "Could not get user information"
                return
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )
            
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    showingError = true
                    errorMessage = error.localizedDescription
                    return
                }
                
                isSignedIn = true
            }
        }
    }
}

struct LaunchIcon: View {
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.black, .green.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 200, height: 200)
                .shadow(color: .black.opacity(0.2), radius: 10)
            
            // Single wrestler
            Image(systemName: "figure.wrestling")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.3), radius: 5)
        }
    }
} 
