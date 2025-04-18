import Foundation
import SwiftUI

class UserManager: ObservableObject {
    @Published var currentUserId: UUID
    @Published var currentUserName: String
    @Published var userTeams: [UUID] = []
    @Published var activeTeamId: UUID?
    
    // Singleton pattern for global access
    static let shared = UserManager()
    
    private init() {
        // Initialize with a default user ID and name
        // In a real app, this would come from authentication
        self.currentUserId = UUID()
        self.currentUserName = "Current User"
        
        // Load user data
        loadUserData()
    }
    
    // MARK: - User Profile
    
    func updateUserProfile(name: String) {
        self.currentUserName = name
        saveUserData()
    }
    
    // MARK: - Team Management
    
    func joinTeam(teamId: UUID) {
        if !userTeams.contains(teamId) {
            userTeams.append(teamId)
            
            // If this is the first team, make it active
            if activeTeamId == nil {
                activeTeamId = teamId
            }
            
            saveUserData()
        }
    }
    
    func leaveTeam(teamId: UUID) {
        userTeams.removeAll { $0 == teamId }
        
        // If active team was removed, select another one if available
        if activeTeamId == teamId {
            activeTeamId = userTeams.first
        }
        
        saveUserData()
    }
    
    func setActiveTeam(teamId: UUID) {
        if userTeams.contains(teamId) {
            activeTeamId = teamId
            saveUserData()
        }
    }
    
    // MARK: - Role & Permission Checks
    
    func getCurrentRole(in teamViewModel: TeamViewModel) -> TeamRole? {
        guard let activeTeamId = activeTeamId,
              let team = teamViewModel.teams.first(where: { $0.id == activeTeamId }) else {
            return nil
        }
        
        // Check if user is the owner
        if team.ownerId == currentUserId {
            return .owner
        }
        
        // Otherwise check member role
        if let member = team.members.first(where: { $0.id == currentUserId }) {
            return member.role
        }
        
        return nil
    }
    
    func canEditTeam(teamId: UUID, in teamViewModel: TeamViewModel) -> Bool {
        guard let team = teamViewModel.teams.first(where: { $0.id == teamId }) else {
            return false
        }
        
        return team.isAdmin(currentUserId)
    }
    
    func canEditPractices(in teamViewModel: TeamViewModel) -> Bool {
        guard let role = getCurrentRole(in: teamViewModel) else {
            return false
        }
        
        return role.canEditPractices
    }
    
    func canViewTeamSettings(in teamViewModel: TeamViewModel) -> Bool {
        guard let role = getCurrentRole(in: teamViewModel) else {
            return false
        }
        
        return role.canViewTeamSettings
    }
    
    // MARK: - Persistence
    
    private func loadUserData() {
        let defaults = UserDefaults.standard
        
        if let userId = defaults.string(forKey: "currentUserId"),
           let userName = defaults.string(forKey: "currentUserName"),
           let teamIds = defaults.stringArray(forKey: "userTeams"),
           let activeTeam = defaults.string(forKey: "activeTeamId") {
            
            self.currentUserId = UUID(uuidString: userId) ?? UUID()
            self.currentUserName = userName
            self.userTeams = teamIds.compactMap { UUID(uuidString: $0) }
            self.activeTeamId = UUID(uuidString: activeTeam)
        }
    }
    
    private func saveUserData() {
        let defaults = UserDefaults.standard
        
        defaults.set(currentUserId.uuidString, forKey: "currentUserId")
        defaults.set(currentUserName, forKey: "currentUserName")
        defaults.set(userTeams.map { $0.uuidString }, forKey: "userTeams")
        
        if let activeTeam = activeTeamId {
            defaults.set(activeTeam.uuidString, forKey: "activeTeamId")
        }
    }
} 