import SwiftUI

struct DefaultTimeSettingView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: PracticeViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                DatePicker(
                    "Default Practice Time",
                    selection: $viewModel.defaultPracticeTime,
                    displayedComponents: .hourAndMinute
                )
            }
            .navigationTitle("Default Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
} 