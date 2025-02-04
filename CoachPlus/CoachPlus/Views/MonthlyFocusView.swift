import SwiftUI

struct MonthlyFocusView: View {
    @ObservedObject var viewModel: PracticeViewModel
    let date: Date
    @Environment(\.dismiss) private var dismiss
    @State private var goals: String = ""
    @State private var focus: String = ""
    
    init(viewModel: PracticeViewModel, date: Date) {
        self.viewModel = viewModel
        self.date = date
        let existingFocus = viewModel.monthlyFocus(for: date)
        _goals = State(initialValue: existingFocus?.goals ?? "")
        _focus = State(initialValue: existingFocus?.focus ?? "")
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Monthly Goals") {
                    TextField("Enter your goals for this month...", text: $goals, axis: .vertical)
                        .lineLimit(4...8)
                }
                
                Section("Monthly Focus") {
                    TextField("Enter your technical/tactical focus...", text: $focus, axis: .vertical)
                        .lineLimit(4...8)
                }
            }
            .navigationTitle(dateFormatter.string(from: date))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let calendar = Calendar.current
                        let focus = MonthlyFocus(
                            month: calendar.component(.month, from: date),
                            year: calendar.component(.year, from: date),
                            goals: goals,
                            focus: focus
                        )
                        viewModel.saveMonthlyFocus(focus)
                        dismiss()
                    }
                }
            }
        }
    }
} 