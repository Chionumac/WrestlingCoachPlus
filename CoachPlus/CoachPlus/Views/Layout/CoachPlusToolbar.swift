import SwiftUI

struct CoachPlusToolbar: ToolbarContent {
    @Binding var showingMonthlyFocus: Bool
    @Binding var showingSearchSheet: Bool
    @Binding var showingDefaultTimeSetting: Bool
    @Binding var showingTutorial: Bool
    @Binding var showingSettings: Bool
    
    var body: some ToolbarContent {
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
                
                Button(action: { showingTutorial = true }) {
                    Label("Tutorial", systemImage: "questionmark.circle")
                }
                
                Button(action: { showingSettings = true }) {
                    Label("Settings", systemImage: "gear")
                }
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.blue)
                    .shadow(color: .blue.opacity(0.3), radius: 4)
            }
        }
    }
} 