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
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.systemBackground),
                        Color(.systemGray6)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
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
                    
                    // Stats Bar - decreased height
                    StatsBar(
                        practices: viewModel.practices,
                        selectedDate: viewModel.selectedDate
                    )
                    .frame(height: 170) // Reduced from 200
                    .padding(.vertical, 4)
                    
                    Spacer(minLength: 10) // Reduced from 20
                    
                    // Quick View - will now have more space
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
            }
            .navigationTitle("COACH+")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 28)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { showingMonthlyFocus = true }) {
                        Label("Monthly Focus", systemImage: "target")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.blue)
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: { showingSearchSheet = true }) {
                            Label("Search", systemImage: "magnifyingglass")
                        }
                        
                        Button(action: { showingDefaultTimeSetting = true }) {
                            Label("Set Default Time", systemImage: "clock")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.blue)
                            .shadow(color: .blue.opacity(0.3), radius: 4)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingTutorial = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                    }
                }
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

struct StatsBar: View {
    let practices: [Practice]
    let selectedDate: Date
    
    private var monthStats: (practices: Int, rest: Int, competitions: Int, lifts: Int, liveTime: Int, intensity: Double) {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: selectedDate)
        let year = calendar.component(.year, from: selectedDate)
        
        let monthPractices = practices.filter {
            let practiceMonth = calendar.component(.month, from: $0.date)
            let practiceYear = calendar.component(.year, from: $0.date)
            return practiceMonth == month && practiceYear == year
        }
        
        let practiceCount = monthPractices.filter { $0.type == .regular }.count
        let restCount = monthPractices.filter { $0.type == .rest }.count
        
        // Group competitions by name to count unique competitions
        let competitions = monthPractices.filter { $0.type == .competition }
        let uniqueCompetitions = Set(competitions.compactMap { practice -> String? in
            practice.sections.first { section in
                section.starts(with: "Competition: ")
            }?.replacingOccurrences(of: "Competition: ", with: "")
        })
        let competitionCount = uniqueCompetitions.count
        
        let liftCount = monthPractices.filter { $0.includesLift }.count
        
        let avgIntensity = monthPractices
            .filter { $0.type != .rest && $0.type != .competition }
            .map { $0.intensity }
            .reduce(0.0, +) / Double(max(practiceCount, 1))
        
        let totalLiveTime = monthPractices
            .map { $0.liveTimeMinutes }
            .reduce(0, +)
        
        return (practiceCount, restCount, competitionCount, liftCount, totalLiveTime, avgIntensity)
    }
    
    private var weekStats: (intensity: Double, liveTime: Int) {
        let calendar = Calendar.current
        let weekOfYear = calendar.component(.weekOfYear, from: selectedDate)
        let year = calendar.component(.year, from: selectedDate)
        
        let weekPractices = practices.filter {
            let practiceWeek = calendar.component(.weekOfYear, from: $0.date)
            let practiceYear = calendar.component(.year, from: $0.date)
            return practiceWeek == weekOfYear && practiceYear == year
        }
        
        let regularPractices = weekPractices.filter { $0.type != .rest && $0.type != .competition }
        let avgIntensity = regularPractices.isEmpty ? 0.0 :
            regularPractices.map { $0.intensity }.reduce(0.0, +) / Double(regularPractices.count)
            
        let totalLiveTime = weekPractices
            .map { $0.liveTimeMinutes }
            .reduce(0, +)
        
        return (avgIntensity, totalLiveTime)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Top Row
            HStack(spacing: 12) {
                // Monthly Practice Count
                StatItem(
                    icon: "figure.run",
                    value: "\(monthStats.practices)",
                    label: "Practices",
                    color: .green
                )
                
                // Monthly Rest Days
                StatItem(
                    icon: "moon.zzz.fill",
                    value: "\(monthStats.rest)",
                    label: "Rest Days",
                    color: .blue
                )
                
                // Monthly Competitions
                StatItem(
                    icon: "trophy.fill",
                    value: "\(monthStats.competitions)",
                    label: "Comp",
                    color: .green
                )
                
                // Monthly Lifts
                StatItem(
                    icon: "dumbbell.fill",
                    value: "\(monthStats.lifts)",
                    label: "Lifts",
                    color: .blue
                )
            }
            
            // Bottom Row
            HStack(spacing: 12) {
                // Monthly Live Time
                StatItem(
                    icon: "timer",
                    value: "\(monthStats.liveTime)",
                    label: "Month Live",
                    color: .blue
                )
                
                // Monthly Intensity
                StatItem(
                    icon: "flame.fill",
                    value: "\(Int(monthStats.intensity * 10))/10",
                    label: "Month Int",
                    color: .green
                )
                
                // Weekly Live Time
                StatItem(
                    icon: "timer",
                    value: "\(weekStats.liveTime)",
                    label: "Week Live",
                    color: .blue
                )
                
                
                // Weekly Intensity
                StatItem(
                    icon: "flame.fill",
                    value: "\(Int(weekStats.intensity * 10))/10",
                    label: "Week Int",
                    color: .green
                )
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .frame(height: 200)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .shadow(
                    color: .black.opacity(0.2),
                    radius: 10,
                    x: 0,
                    y: 4
                )
        )
        .padding(.horizontal)
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(color)
                .shadow(color: color.opacity(0.3), radius: 2)
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 15, weight: .bold))
                
                Text(label)
                    .font(.system(size: 10))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 70)
        .padding(.vertical, 6)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        )
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
