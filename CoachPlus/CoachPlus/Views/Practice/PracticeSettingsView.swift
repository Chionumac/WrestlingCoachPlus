import SwiftUI

struct PracticeSettingsView: View {
    @Binding var liveTimeMinutes: Int
    @Binding var includesLift: Bool
    @Binding var intensity: Double
    
    var body: some View {
        VStack(spacing: 24) {
            // Live Minutes
            HStack {
                Text("Live Minutes")
                    .font(.headline)
                
                Spacer()
                
                Menu {
                    ForEach([0, 15, 30, 45, 60], id: \.self) { minutes in
                        Button(minutes == 0 ? "None" : "\(minutes)m") {
                            liveTimeMinutes = minutes
                        }
                    }
                } label: {
                    Text(liveTimeMinutes == 0 ? "None" : "\(liveTimeMinutes)m")
                        .foregroundStyle(.secondary)
                }
            }
            
            // Lift Toggle
            HStack {
                Text("Lift")
                    .font(.headline)
                
                Spacer()
                
                Toggle("", isOn: $includesLift)
                    .tint(.blue)
            }
            
            // Practice Intensity
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Practice Intensity")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(Int(intensity * 10))/10")
                        .foregroundStyle(.secondary)
                }
                
                Slider(value: $intensity, in: 0...1, step: 0.1)
                    .tint(
                        LinearGradient(
                            colors: [.green, .yellow, .orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        )
        .padding(.horizontal)
    }
}

#Preview {
    PracticeSettingsView(
        liveTimeMinutes: .constant(30),
        includesLift: .constant(false),
        intensity: .constant(0.5)
    )
    .preferredColorScheme(.dark)
} 