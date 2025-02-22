import SwiftUI

enum SliderStyle {
    case intensity    // 1 (green) to 10 (red)
    case performance  // 1 (red) to 10 (green)
}

struct IntensitySlider: View {
    @Binding var intensity: Double
    let title: String
    let style: SliderStyle
    
    var color: Color {
        let hue = style == .intensity 
            ? 0.3 * (1 - intensity)  // Goes from green (0.3) to red (0.0)
            : 0.3 * intensity        // Goes from red (0.0) to green (0.3)
        
        return Color(
            hue: max(0, min(0.3, hue)),
            saturation: 0.7,
            brightness: 0.7
        )
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Text("\(Int(intensity * 10))/10")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 12) {
                Text("1")
                    .font(.subheadline)
                    .foregroundStyle(style == .intensity ? .green : .red)
                
                Slider(value: $intensity, in: 0...1, step: 0.1) { _ in
                    // Round to nearest 0.1 after sliding
                    intensity = round(intensity * 10) / 10
                }
                .tint(color)
                
                Text("10")
                    .font(.subheadline)
                    .foregroundStyle(style == .intensity ? .red : .green)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

#Preview {
    VStack(spacing: 20) {
        IntensitySlider(
            intensity: .constant(0.3),
            title: "Practice Intensity",
            style: .intensity
        )
        
        IntensitySlider(
            intensity: .constant(0.7),
            title: "Performance",
            style: .performance
        )
    }
    .padding()
} 