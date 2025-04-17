import SwiftUI

// Add this line to import Team model
@_implementationOnly import struct CoachPlus.Team

struct TeamsListView: View {
    @StateObject private var viewModel = TeamViewModel()
    @State private var showingAddTeam = false
    @State private var newTeamName = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.teams.isEmpty {
                    emptyTeamsView
                } else {
                    teamsList
                }
            }
            .navigationTitle("Teams")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showingAddTeam = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTeam) {
                addTeamSheet
            }
        }
    }
    
    private var emptyTeamsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
                .symbolRenderingMode(.hierarchical)
            
            Text("No Teams")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Create a team to collaborate with coaches and athletes")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 40)
            
            Button(action: {
                showingAddTeam = true
            }) {
                Text("Create Team")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: 280)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }
            .padding(.top, 10)
        }
        .padding(.bottom, 60)
    }
    
    private var teamsList: some View {
        List {
            ForEach(viewModel.teams) { team in
                NavigationLink(destination: TeamDetailView(viewModel: viewModel, teamId: team.id)) {
                    TeamRow(team: team)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        viewModel.deleteTeam(id: team.id)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }
    
    private var addTeamSheet: some View {
        NavigationStack {
            Form {
                Section(header: Text("Team Name")) {
                    TextField("Enter team name", text: $newTeamName)
                }
                
                Section {
                    Button("Create Team") {
                        if !newTeamName.isEmpty {
                            viewModel.createTeam(name: newTeamName)
                            newTeamName = ""
                            showingAddTeam = false
                        }
                    }
                    .disabled(newTeamName.isEmpty)
                    
                    Button("Cancel", role: .cancel) {
                        showingAddTeam = false
                    }
                }
            }
            .navigationTitle("New Team")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
    }
}

struct TeamRow: View {
    let team: Team
    
    var body: some View {
        HStack {
            Image(systemName: "person.3.fill")
                .foregroundStyle(.blue)
                .symbolRenderingMode(.hierarchical)
            
            VStack(alignment: .leading) {
                Text(team.name)
                    .font(.headline)
                
                Text("\(team.members.count) members")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Status indicator
            Circle()
                .fill(team.isActive ? Color.green : Color.red)
                .frame(width: 10, height: 10)
        }
    }
}

#Preview {
    TeamsListView()
} 