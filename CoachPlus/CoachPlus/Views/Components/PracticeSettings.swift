import SwiftUI

struct PracticeSettings: View {
    @Binding var liveTimeMinutes: Int
    @Binding var includesLift: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Live Minutes")
                    .font(.headline)
                
                Spacer()
                
                Picker("", selection: $liveTimeMinutes) {
                    ForEach(0...60, id: \.self) { minutes in
                        Text(minutes == 0 ? "None" : "\(minutes) min")
                            .tag(minutes)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .frame(width: 100)
                .tint(.gray)
                .labelsHidden()
            }
            .padding(.horizontal)
            
            Toggle(isOn: $includesLift) {
                Text("Lift")
                    .font(.headline)
            }
            .padding(.horizontal)
            .tint(.orange)
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
}

#Preview {
    VStack {
        PracticeSettings(
            liveTimeMinutes: .constant(30),
            includesLift: .constant(true)
        )
        PracticeSettings(
            liveTimeMinutes: .constant(0),
            includesLift: .constant(false)
        )
    }
    .padding()
} 