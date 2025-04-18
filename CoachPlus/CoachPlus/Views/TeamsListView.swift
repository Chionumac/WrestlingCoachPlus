import SwiftUI

struct TeamsListView: View {
    @StateObject private var viewModel = TeamViewModel()
    @State private var showingAddTeam = false
    @State private var newTeamName = ""
    @State private var showingSignIn = false
    @State private var teamCode = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.userTeams.isEmpty {
                    emptyTeamsView
                } else {
                    teamsList
                }
            }
            .navigationTitle("My Teams")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(action: {
                            showingAddTeam = true
                        }) {
                            Label("Create New Team", systemImage: "plus")
                        }
                        
                        Button(action: {
                            showingSignIn = true
                        }) {
                            Label("Join Existing Team", systemImage: "person.badge.key")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTeam) {
                addTeamSheet
            }
            .sheet(isPresented: $showingSignIn) {
                signInSheet
            }
        }
        .environmentObject(UserManager.shared)
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
            
            Text("Create a team or sign in to collaborate with coaches and athletes")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 40)
            
            VStack(spacing: 12) {
                Button(action: {
                    showingAddTeam = true
                }) {
                    Text("Create New Team")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: 280)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    showingSignIn = true
                }) {
                    Text("Sign In to Existing Team")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: 280)
                        .background(Color.blue.opacity(0.1))
                        .foregroundStyle(.blue)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                }
            }
            .padding(.top, 10)
        }
        .padding(.bottom, 60)
    }
    
    private var teamsList: some View {
        List {
            ForEach(viewModel.userTeams) { team in
                NavigationLink(destination: TeamDetailView(viewModel: viewModel, teamId: team.id)) {
                    TeamRow(team: team)
                        .contextMenu {
                            if team.ownerId == UserManager.shared.currentUserId {
                                Button(role: .destructive) {
                                    viewModel.deleteTeam(id: team.id)
                                } label: {
                                    Label("Delete Team", systemImage: "trash")
                                }
                            } else {
                                Button(role: .destructive) {
                                    viewModel.leaveTeam(teamId: team.id)
                                } label: {
                                    Label("Leave Team", systemImage: "rectangle.portrait.and.arrow.right")
                                }
                            }
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
    
    private var signInSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "person.badge.key.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.blue)
                
                Text("Sign In to Team")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("Enter the team code provided by your coach or team manager")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 30)
                
                TextField("Team Code", text: $teamCode)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding()
                    .autocapitalization(.allCharacters)
                    .autocorrectionDisabled()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal, 50)
                    .padding(.top, 20)
                
                if let error = viewModel.joinError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.top, 8)
                }
                
                Button(action: {
                    viewModel.joinTeamWithCode(teamCode)
                    if case .success = viewModel.state {
                        teamCode = ""
                        showingSignIn = false
                    }
                }) {
                    Text("Join Team")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(teamCode.isEmpty ? Color.gray : Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }
                .disabled(teamCode.isEmpty)
                .padding(.horizontal, 50)
                .padding(.top, 20)
                
                Button("Cancel") {
                    teamCode = ""
                    showingSignIn = false
                }
                .padding(.top)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Join Team")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
    }
}

struct TeamRow: View {
    let team: Team
    @EnvironmentObject private var userManager: UserManager
    
    var body: some View {
        HStack {
            Image(systemName: "person.3.fill")
                .foregroundStyle(.blue)
                .symbolRenderingMode(.hierarchical)
            
            VStack(alignment: .leading) {
                Text(team.name)
                    .font(.headline)
                
                HStack {
                    Text("\(team.members.count) members")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if team.ownerId == userManager.currentUserId {
                        Text("Owner")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .foregroundStyle(.blue)
                            .cornerRadius(4)
                    }
                }
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