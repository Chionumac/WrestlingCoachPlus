import SwiftUI
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift


struct LoginView: View {
    @State private var isAuthenticated = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        Group {
            if isAuthenticated {
                LaunchScreenView()
            } else {
                VStack(spacing: 20) {
                    Spacer()
                    
                    // App Logo/Title
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 60)
                        .padding(.bottom, 20)
                    
                    Spacer()
                    
                    // Google Sign In Button
                    GoogleSignInButton(scheme: .dark, style: .wide) {
                        handleSignIn()
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
                .alert("Authentication Error", isPresented: $showError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(errorMessage)
                }
            }
        }
        .onAppear {
            checkAuthStatus()
            checkGoogleServiceInfo()
        }
    }
    
    private func checkAuthStatus() {
        if Auth.auth().currentUser != nil {
            isAuthenticated = true
        }
    }
    
    private func handleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Failed to get clientID")
            return 
        }
        print("Using clientID: \(clientID)")
        
        _ = GIDConfiguration(clientID: clientID)
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("Failed to get rootViewController")
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            if let error = error {
                print("Sign in error: \(error.localizedDescription)")
                errorMessage = error.localizedDescription
                showError = true
                return
            }
            
            guard let signInResult = signInResult else {
                print("No sign in result")
                return
            }
            
            guard let idToken = signInResult.user.idToken?.tokenString else {
                print("Failed to get idToken")
                return
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: signInResult.user.accessToken.tokenString
            )
            
            Task {
                do {
                    let result = try await Auth.auth().signIn(with: credential)
                    print("Successfully signed in: \(result.user.uid)")
                    isAuthenticated = true
                } catch {
                    print("Firebase sign in error: \(error.localizedDescription)")
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    private func checkGoogleServiceInfo() {
        if let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
            print("GoogleService-Info.plist found at: \(filePath)")
            
            // Read and print contents to verify
            if let dict = NSDictionary(contentsOfFile: filePath) {
                print("File contents:")
                print("CLIENT_ID: \(dict["CLIENT_ID"] ?? "Not found")")
                print("REVERSED_CLIENT_ID: \(dict["REVERSED_CLIENT_ID"] ?? "Not found")")
                print("BUNDLE_ID: \(dict["BUNDLE_ID"] ?? "Not found")")
            } else {
                print("Failed to read plist contents")
            }
        } else {
            print("ERROR: GoogleService-Info.plist not found in bundle!")
        }
    }
} 
