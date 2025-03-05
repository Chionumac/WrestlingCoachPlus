import SwiftUI

struct TrialBannerView: View {
    let endDate: Date
    @State private var timeRemaining: TimeInterval = 0
    @State private var showPaywall = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack {
            Image(systemName: "clock")
                .foregroundStyle(.blue)
            
            if timeRemaining <= 24 * 60 * 60 { // Less than 24 hours
                Text("Trial ends in \(formatTime(timeRemaining))")
            } else {
                Text("\(Int(timeRemaining / (24 * 60 * 60))) days left in trial")
            }
            
            Spacer()
            
            if timeRemaining <= 24 * 60 * 60 { // Show subscribe button in last 24 hours
                Button("Subscribe") {
                    showPaywall = true
                }
                .foregroundStyle(.blue)
            }
        }
        .font(.subheadline)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .onAppear {
            updateTimeRemaining()
        }
        .onReceive(timer) { _ in
            updateTimeRemaining()
        }
    }
    
    private func updateTimeRemaining() {
        timeRemaining = endDate.timeIntervalSince(Date())
        if timeRemaining < 0 {
            timeRemaining = 0
        }
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
} 