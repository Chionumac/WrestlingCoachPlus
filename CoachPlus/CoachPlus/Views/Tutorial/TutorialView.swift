import SwiftUI

struct TutorialStep {
    let title: String
    let description: String
    let icon: String
    let images: [String]
    let action: (() -> Void)?
}

struct TutorialView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0
    
    let steps: [TutorialStep] = [
        // Welcome
        TutorialStep(
            title: "Welcome to Coach+",
            description: "Let's walk through the key features to help you plan and manage your wrestling practices effectively.",
            icon: "hand.wave.fill",
            images: [],
            action: nil
        ),
        
        // Calendar Navigation
        TutorialStep(
            title: "Calendar Navigation",
            description: "• Dates are color coded by practice intensity or competition performance\n• Icons show lifts and competitions \n• Double tap any date to add or view an event",
            icon: "calendar",
            images: ["calendar_tutorial"],
            action: nil
        ),
        
        // Stat Bar & Quick View
        TutorialStep(
            title: "Stat Bar & Quick View",
            description: "• Track monthly totals for practices, lifts, rest days, and competitions\n• Monitor monthly and weekly live minutes and intensity averages\n• Quick view shows selected date's practice summary and metrics",
            icon: "chart.bar.fill",
            images: ["stats_tutorial"],
            action: nil
        ),
        
        // Add Event
        TutorialStep(
            title: "Add Event",
            description: "After double-tapping an empty date, choose your event type:\n• Practice\n• Competition\n• Rest Day\n• Start from Template",
            icon: "plus.circle.fill",
            images: ["add_event_tutorial"],
            action: nil
        ),
        
        // Add Practice
        TutorialStep(
            title: "Add Practice",
            description: "• Build practices with customizable blocks\n• Use block menu to save, search, delete, or insert blocks\n• Track live minutes and toggle lifts\n• Intensity slider affects calendar date color\n• Save via button or swipe down\n• Menu options for repeating practices and templates",
            icon: "figure.wrestling",
            images: ["add_practice_tutorial", "add_practice_tutorial_2"],
            action: nil
        ),
        
        // Add Competition
        TutorialStep(
            title: "Add Competition",
            description: "• Record competition results and video links\n• Add detailed notes\n• Performance slider changes calendar date color\n• Track competition outcomes and progress",
            icon: "trophy.fill",
            images: ["add_competition_tutorial"],
            action: nil
        ),
        
        // Monthly Focus & Goals
        TutorialStep(
            title: "Monthly Focus & Goals",
            description: "Set and track your team's:\n• Monthly focus areas\n• Performance goals\n• Training objectives",
            icon: "target",
            images: ["monthly_focus_tutorial"],
            action: nil
        ),
        
        // Search
        TutorialStep(
            title: "Search",
            description: "Find past practices and competitions:\n• Search by keywords\n• Filter by performance rating\n• Review practice blocks and competition results",
            icon: "magnifyingglass",
            images: ["search_tutorial"],
            action: nil
        )
    ]
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Progress dots
                HStack(spacing: 6) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentStep ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top)
                
                // Icon
                Image(systemName: steps[currentStep].icon)
                    .font(.system(size: 44))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .green.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.vertical, 8)
                
                // Content
                VStack(spacing: 12) {
                    Text(steps[currentStep].title)
                        .font(.title2.bold())
                    
                    // Tutorial images if available
                    if !steps[currentStep].images.isEmpty {
                        TabView {
                            ForEach(steps[currentStep].images, id: \.self) { imageName in
                                Image(imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 200)
                                    .cornerRadius(12)
                                    .shadow(radius: 5)
                                    .padding(.horizontal)
                            }
                        }
                        .frame(height: 220)
                        .tabViewStyle(.page)
                    }
                    
                    Text(steps[currentStep].description)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                // Navigation buttons
                HStack {
                    if currentStep > 0 {
                        Button("Back") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button(currentStep == steps.count - 1 ? "Get Started" : "Next") {
                        if currentStep == steps.count - 1 {
                            dismiss()
                        } else {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .padding()
        }
    }
}

#Preview {
    TutorialView()
} 
