import SwiftUI

struct SettingsView: View {
    @AppStorage("sliderMetricName") var sliderMetricName: String = "Avg Intensity"
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Personalization")) {
                    TextField("Slider Metric Name", text: $sliderMetricName)
                        .autocapitalization(.words)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
} 