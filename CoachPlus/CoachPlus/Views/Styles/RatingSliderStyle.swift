import SwiftUI

struct RatingSliderView: View {
    @Binding var rating: Double
    let title: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                Spacer()
                Text("\(Int(rating * 10))/10")
                    .foregroundStyle(.secondary)
            }
            
            Slider(value: $rating, in: 0...1) {
                Text(title)
            } minimumValueLabel: {
                Text("Poor")
                    .font(.caption)
                    .foregroundStyle(.red)
            } maximumValueLabel: {
                Text("Great")
                    .font(.caption)
                    .foregroundStyle(.green)
            }
            .tint(
                Color(
                    hue: 0.3 * rating,
                    saturation: 0.8,
                    brightness: 0.9
                )
            )
        }
    }
}

#Preview {
    VStack {
        RatingSliderView(rating: .constant(0.3), title: "Performance")
        RatingSliderView(rating: .constant(0.7), title: "Intensity")
    }
    .padding()
} 