import Foundation
import SwiftUI

class TeamViewModel: ObservableObject {
    @Published var teams: [Team] = []
    @Published var state: ViewState = .idle
    @Published var joinError: String?
    
    enum ViewState {
        case idle
        case loading
        case error(Error)
        case success
    }
    
    private let storageKey = "teams_data"
    
    init() {
        loadTeams()
    }
    
    // MARK: - Team Management
    
    func createTeam(name: String) {
        let currentUser = UserManager.shared
        
        // Create a new member for the current user as owner
        let ownerMember = TeamMember(
            id: currentUser.currentUserId,
            name: currentUser.currentUserName,
            role: .owner
        )
        
        // Create the team with the current user as owner
        let newTeam = Team(
            name: name,
            members: [ownerMember],
            ownerId: currentUser.currentUserId
        )
        
        teams.append(newTeam)
        saveTeams()
        
        // Add this team to the user's teams
        currentUser.joinTeam(teamId: newTeam.id)
    }
    
    func updateTeam(id: UUID, name: String, isActive: Bool) {
        if let index = teams.firstIndex(where: { $0.id == id }) {
            // Check if user has permissions to edit this team
            if UserManager.shared.canEditTeam(teamId: id, in: self) {
                teams[index].name = name
                teams[index].isActive = isActive
                saveTeams()
            }
        }
    }
    
    func deleteTeam(id: UUID) {
        let team = teams.first(where: { $0.id == id })
        
        // Only allow deletion if user is the owner
        if let team = team, team.ownerId == UserManager.shared.currentUserId {
            teams.removeAll { $0.id == id }
            saveTeams()
            
            // Remove from user's teams
            UserManager.shared.leaveTeam(teamId: id)
        }
    }
    
    // MARK: - Team Join/Leave Functions
    
    func joinTeamWithCode(_ code: String) {
        state = .loading
        joinError = nil
        
        // Find team with matching code
        if let team = teams.first(where: { $0.inviteCode.uppercased() == code.uppercased() }) {
            // Check if user is already a member
            let currentUserId = UserManager.shared.currentUserId
            if team.members.contains(where: { $0.id == currentUserId }) {
                joinError = "You are already a member of this team"
                state = .idle
                return
            }
            
            // Add user as a team member with athlete role by default
            addMember(
                teamId: team.id,
                name: UserManager.shared.currentUserName,
                role: .athlete,
                memberId: currentUserId
            )
            
            // Add this team to the user's teams
            UserManager.shared.joinTeam(teamId: team.id)
            
            state = .success
        } else {
            joinError = "Invalid team code. Please check and try again."
            state = .idle
        }
    }
    
    func leaveTeam(teamId: UUID) {
        let currentUserId = UserManager.shared.currentUserId
        
        // Find the team
        if let index = teams.firstIndex(where: { $0.id == teamId }) {
            // Check if user is the owner - owners can't leave, must delete
            if teams[index].ownerId == currentUserId {
                joinError = "As the owner, you cannot leave the team. You can delete it instead."
                return
            }
            
            // Remove the user from team members
            teams[index].members.removeAll { $0.id == currentUserId }
            saveTeams()
            
            // Remove from user's teams
            UserManager.shared.leaveTeam(teamId: teamId)
        }
    }
    
    func regenerateTeamCode(teamId: UUID) -> String? {
        if let index = teams.firstIndex(where: { $0.id == teamId }) {
            // Check if user has permissions to edit this team
            if UserManager.shared.canEditTeam(teamId: teamId, in: self) {
                let newCode = Team.generateInviteCode()
                teams[index].inviteCode = newCode
                saveTeams()
                return newCode
            }
        }
        return nil
    }
    
    // MARK: - Team Member Management
    
    func addMember(teamId: UUID, name: String, role: TeamRole, memberId: UUID? = nil) {
        if let index = teams.firstIndex(where: { $0.id == teamId }) {
            // Only allow if user has admin privileges
            if UserManager.shared.canEditTeam(teamId: teamId, in: self) {
                let id = memberId ?? UUID()
                let newMember = TeamMember(id: id, name: name, role: role)
                teams[index].members.append(newMember)
                saveTeams()
            }
        }
    }
    
    func updateMemberRole(teamId: UUID, memberId: UUID, newRole: TeamRole) {
        if let teamIndex = teams.firstIndex(where: { $0.id == teamId }) {
            // Only allow if user has admin privileges
            if UserManager.shared.canEditTeam(teamId: teamId, in: self) {
                if let memberIndex = teams[teamIndex].members.firstIndex(where: { $0.id == memberId }) {
                    teams[teamIndex].members[memberIndex].role = newRole
                    saveTeams()
                }
            }
        }
    }
    
    func removeMember(teamId: UUID, memberId: UUID) {
        if let teamIndex = teams.firstIndex(where: { $0.id == teamId }) {
            // Don't allow removing the owner
            if teams[teamIndex].ownerId == memberId {
                return
            }
            
            // Only allow if user has admin privileges
            if UserManager.shared.canEditTeam(teamId: teamId, in: self) {
                teams[teamIndex].members.removeAll { $0.id == memberId }
                saveTeams()
            }
        }
    }
    
    // MARK: - Filtered Team Functions
    
    /// Get teams for the current user
    var userTeams: [Team] {
        let userTeamIds = UserManager.shared.userTeams
        return teams.filter { userTeamIds.contains($0.id) }
    }
    
    /// Get the currently active team
    var activeTeam: Team? {
        guard let activeTeamId = UserManager.shared.activeTeamId else {
            return nil
        }
        return teams.first { $0.id == activeTeamId }
    }
    
    // MARK: - Persistence
    
    private func loadTeams() {
        if let data = UserDefaults.standard.data(forKey: storageKey) {
            do {
                let decodedTeams = try JSONDecoder().decode([Team].self, from: data)
                self.teams = decodedTeams
            } catch {
                self.state = .error(error)
                print("Error loading teams: \(error)")
            }
        }
    }
    
    private func saveTeams() {
        do {
            let data = try JSONEncoder().encode(teams)
            UserDefaults.standard.set(data, forKey: storageKey)
            self.state = .success
        } catch {
            self.state = .error(error)
            print("Error saving teams: \(error)")
        }
    }
} 