import SwiftUI

struct TutorialImageView: View {
    let imageName: String
    let caption: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .cornerRadius(12)
                .shadow(radius: 5)
            
            Text(caption)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
} 