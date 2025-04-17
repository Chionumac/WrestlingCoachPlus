import SwiftUI

struct TeamDetailView: View {
    @ObservedObject var viewModel: TeamViewModel
    let teamId: UUID
    @State private var isEditing = false
    @State private var teamName = ""
    @State private var showingAddMember = false
    @State private var newMemberName = ""
    @State private var newMemberRole: TeamRole = .athlete
    @Environment(\.dismiss) private var dismiss
    
    private var team: Team? {
        viewModel.teams.first(where: { $0.id == teamId })
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Team header
                teamHeader
                
                Divider()
                
                // Members list
                membersSection
                
                Divider()
                
                // Team info
                infoSection
            }
            .padding()
        }
        .navigationTitle(team?.name ?? "Team Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                editButton
            }
        }
        .sheet(isPresented: $showingAddMember) {
            addMemberSheet
        }
    }
    
    private var teamHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if isEditing {
                    TextField("Team Name", text: $teamName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.vertical, 4)
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                } else {
                    Text(team?.name ?? "")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Text("Created: \(formattedDate)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "person.3.fill")
                .font(.title)
                .foregroundStyle(.blue)
                .symbolRenderingMode(.hierarchical)
        }
    }
    
    private var membersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Team Members")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    showingAddMember = true
                }) {
                    Label("Add", systemImage: "plus.circle")
                        .font(.subheadline)
                }
            }
            
            if let team = team, !team.members.isEmpty {
                ForEach(team.members) { member in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(member.name)
                                .font(.body)
                            
                            Text(member.role.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if isEditing {
                            Button(action: {
                                viewModel.removeMember(teamId: teamId, memberId: member.id)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            } else {
                Text("No members yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            }
        }
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Team Info")
                .font(.headline)
            
            HStack {
                Text("Status:")
                
                if let team = team {
                    Text(team.isActive ? "Active" : "Inactive")
                        .foregroundStyle(team.isActive ? .green : .red)
                }
                
                if isEditing, let team = team {
                    Button(action: {
                        viewModel.updateTeam(
                            id: teamId,
                            name: team.name,
                            isActive: !team.isActive
                        )
                    }) {
                        Text("Toggle")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }
            
            Text("Total Members: \(team?.members.count ?? 0)")
        }
    }
    
    private var editButton: some View {
        Button(action: {
            if isEditing {
                saveChanges()
            }
            isEditing.toggle()
            
            if isEditing, let team = team {
                teamName = team.name
            }
        }) {
            Text(isEditing ? "Save" : "Edit")
        }
    }
    
    private var addMemberSheet: some View {
        NavigationStack {
            Form {
                Section(header: Text("New Member Details")) {
                    TextField("Name", text: $newMemberName)
                    
                    Picker("Role", selection: $newMemberRole) {
                        ForEach(TeamRole.allCases, id: \.self) { role in
                            Text(role.description).tag(role)
                        }
                    }
                }
                
                Section {
                    Button("Add Member") {
                        if !newMemberName.isEmpty, let teamId = team?.id {
                            viewModel.addMember(
                                teamId: teamId,
                                name: newMemberName,
                                role: newMemberRole
                            )
                            newMemberName = ""
                            showingAddMember = false
                        }
                    }
                    .disabled(newMemberName.isEmpty)
                    
                    Button("Cancel", role: .cancel) {
                        showingAddMember = false
                    }
                }
            }
            .navigationTitle("Add Team Member")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
    }
    
    private var formattedDate: String {
        guard let date = team?.createdDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func saveChanges() {
        guard let team = team, !teamName.isEmpty else { return }
        viewModel.updateTeam(
            id: team.id,
            name: teamName,
            isActive: team.isActive
        )
    }
}

#Preview {
    NavigationStack {
        let viewModel = TeamViewModel()
        let team = Team(name: "Sample Team", members: [
            TeamMember(name: "John Doe", role: .coach),
            TeamMember(name: "Jane Smith", role: .athlete),
            TeamMember(name: "Mike Johnson", role: .assistant)
        ])
        viewModel.teams.append(team)
        
        return TeamDetailView(viewModel: viewModel, teamId: team.id)
    }
} 