import SwiftUI

struct PracticeSummaryView: View {
    @Binding var summary: String
    @Binding var showingSummaryError: Bool
    @Binding var practiceTime: Date
    let date: Date
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Date and Time header
            HStack {
                Text(dateFormatter.string(from: date))
                    .font(.title2.weight(.medium))
                
                Spacer()
                
                DatePicker("", selection: $practiceTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .font(.title2.weight(.medium))
                    .tint(.secondary)
            }
            .foregroundStyle(.secondary)
            .padding(.vertical, 12)
            
            // Summary TextField
            TextField("Practice Summary", text: $summary, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...6)
                .overlay {
                    if showingSummaryError {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(.red, lineWidth: 1)
                    }
                }
        }
        .padding(.horizontal)
    }
}

#Preview {
    PracticeSummaryView(
        summary: .constant("Test Practice"),
        showingSummaryError: .constant(false),
        practiceTime: .constant(Date()),
        date: Date()
    )
} 