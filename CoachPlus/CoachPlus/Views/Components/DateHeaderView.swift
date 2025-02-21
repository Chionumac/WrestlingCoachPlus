import SwiftUI

struct DateHeaderView: View {
    let date: Date
    @Binding var practiceTime: Date
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter
    }()
    
    var body: some View {
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
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    DateHeaderView(
        date: Date(),
        practiceTime: .constant(Date())
    )
} 