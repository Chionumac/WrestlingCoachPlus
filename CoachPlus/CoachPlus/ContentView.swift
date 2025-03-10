//
//  ContentView.swift
//  CoachPlus
//
//  Created by Christopher Chinonuma on 1/21/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PracticeViewModel()
    @State private var showingAddPractice = false
    @State private var showingPracticeDetails = false
    @State private var showingMonthlyFocus = false
    @State private var showingSearchSheet = false
    @State private var showingDefaultTimeSetting = false
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial = false
    @State private var showingTutorial = false
    @State private var showPaywall = false
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    var body: some View {
        NavigationStack {
            MainLayout(content: AnyView(
                VStack(spacing: 0) {
                    // Calendar View
                    CalendarView(
                        selectedDate: $viewModel.selectedDate,
                        showingAddPractice: $showingAddPractice,
                        showingPracticeDetails: $showingPracticeDetails,
                        practices: viewModel.practices
                    )
                    .frame(height: UIScreen.main.bounds.height * 0.48)
                    .padding(.top)
                    
                    // Stats Bar - Updated to use StatsViewModel
                    StatsBar(
                        viewModel: viewModel.statsViewModel,
                        selectedDate: viewModel.selectedDate
                    )
                    .frame(height: 170)
                    .padding(.vertical, 4)
                    
                    Spacer(minLength: 10)
                    
                    // Quick View
                    ScrollView {
                        QuickViewContainer(
                            practice: viewModel.practiceForDate(viewModel.selectedDate),
                            onTap: {
                                if viewModel.practiceForDate(viewModel.selectedDate) != nil {
                                    showingPracticeDetails = true
                                }
                            }
                        )
                        .padding(.vertical)
                    }
                }
            ))
            .navigationTitle("COACH+")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                CoachPlusToolbar(
                    showingMonthlyFocus: $showingMonthlyFocus,
                    showingSearchSheet: $showingSearchSheet,
                    showingDefaultTimeSetting: $showingDefaultTimeSetting,
                    showingTutorial: $showingTutorial
                )
            }
            .sheet(isPresented: $showingAddPractice) {
                AddPracticeView(
                    date: viewModel.selectedDate,
                    viewModel: viewModel,
                    onSave: {
                        showingAddPractice = false
                    }
                )
            }
            .sheet(isPresented: $showingPracticeDetails) {
                if let practice = viewModel.practiceForDate(viewModel.selectedDate) {
                    NavigationStack {
                        if practice.type == .competition {
                            AddCompetitionView(
                                date: viewModel.selectedDate,
                                viewModel: viewModel,
                                editingPractice: practice,
                                onSave: {
                                    showingPracticeDetails = false
                                }
                            )
                        } else {
                            PracticeEntryView(
                                date: practice.date,
                                viewModel: viewModel,
                                editingPractice: practice,
                                onSave: {
                                    showingPracticeDetails = false
                                }
                            )
                        }
                    }
                }
            }
            .sheet(isPresented: $showingMonthlyFocus) {
                MonthlyFocusView(
                    viewModel: viewModel,
                    date: viewModel.selectedDate
                )
            }
            .sheet(isPresented: $showingSearchSheet) {
                UnifiedSearchView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingDefaultTimeSetting) {
                DefaultTimeSettingView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingTutorial) {
                TutorialView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
        .onAppear {
            if !hasSeenTutorial {
                showingTutorial = true
                hasSeenTutorial = true
            }
        }
    }
}

// Breaking down into smaller components
struct QuickViewContainer: View {
    let practice: Practice?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                if let practice = practice {
                    switch practice.type {
                    case .competition:
                        CompetitionQuickSummary(practice: practice)
                    default:
        PracticeQuickView(practice: practice)
                    }
                } else {
                    EmptyPracticeView()
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(practice == nil)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct CompetitionQuickSummary: View {
    let practice: Practice
    
    private var competitionDetails: (name: String, results: String, video: String, notes: String, performance: String) {
        var name = "", results = "", video = "", notes = "", performance = ""
        
        for section in practice.sections {
            if section.starts(with: "Competition: ") {
                name = section.replacingOccurrences(of: "Competition: ", with: "")
            } else if section.starts(with: "Results: ") {
                results = section.replacingOccurrences(of: "Results: ", with: "")
            } else if section.starts(with: "Video: ") {
                video = section.replacingOccurrences(of: "Video: ", with: "")
            } else if section.starts(with: "Performance: ") {
                performance = section.replacingOccurrences(of: "Performance: ", with: "")
            } else {
                notes = section
            }
        }
        
        return (name, results, video, notes, performance)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with competition icon and name
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
                    .shadow(color: .green.opacity(0.3), radius: 4)
                
                Text(competitionDetails.name)
                    .font(.headline)
                
                Spacer()
                
                // Performance medal
                Image(systemName: "medal.fill")
                    .foregroundStyle(.yellow)
                    .shadow(color: .yellow.opacity(0.3), radius: 4)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                    )
            }
            
            // Links Section
            VStack(alignment: .leading, spacing: 8) {
                if !competitionDetails.results.isEmpty {
                    Link(destination: URL(string: competitionDetails.results) ?? URL(string: "https://")!) {
                        HStack {
                            Image(systemName: "list.clipboard")
                            Text("Results")
                        }
                        .foregroundStyle(.blue)
                    }
                }
                
                if !competitionDetails.video.isEmpty {
                    Link(destination: URL(string: competitionDetails.video) ?? URL(string: "https://")!) {
                        HStack {
                            Image(systemName: "video")
                            Text("Video")
                        }
                        .foregroundStyle(.blue)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if !competitionDetails.notes.isEmpty {
                Text(competitionDetails.notes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Text("Tap to view details")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        )
    }
}

struct AddButton: View {
    @Binding var showingAddPractice: Bool
    
    var body: some View {
        Button(action: { showingAddPractice = true }) {
            Image(systemName: "plus.circle.fill")
                .font(.title2)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.blue)
                .shadow(color: .blue.opacity(0.3), radius: 4)
        }
    }
}

#Preview {
    ContentView()
}

// Add custom title styling
extension View {
    func navigationBarTitleTextStyle() -> some View {
        self.modifier(NavigationBarTitleModifier())
    }
}

struct NavigationBarTitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("HelveticaNeue-CondensedBold", size: 22))
            .tracking(2) // Letter spacing
            .foregroundStyle(
                LinearGradient(
                    colors: [.blue, .blue.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
}

struct StatBox: View {
    let icon: String
    let value: Int
    let label: String
    var iconColor: Color = .primary // Added color parameter with default
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor) // Use the passed color
                .shadow(color: iconColor.opacity(0.3), radius: 4) // Added shadow for better visibility
            
            Text("\(value)")
                .font(.title3.bold())
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
