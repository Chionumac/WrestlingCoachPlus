import Foundation
import SwiftUI

class TeamViewModel: ObservableObject {
    @Published var teams: [Team] = []
    @Published var state: ViewState = .idle
    
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
        let newTeam = Team(name: name)
        teams.append(newTeam)
        saveTeams()
    }
    
    func updateTeam(id: UUID, name: String, isActive: Bool) {
        if let index = teams.firstIndex(where: { $0.id == id }) {
            teams[index].name = name
            teams[index].isActive = isActive
            saveTeams()
        }
    }
    
    func deleteTeam(id: UUID) {
        teams.removeAll { $0.id == id }
        saveTeams()
    }
    
    // MARK: - Team Member Management
    
    func addMember(teamId: UUID, name: String, role: TeamRole) {
        if let index = teams.firstIndex(where: { $0.id == teamId }) {
            let newMember = TeamMember(name: name, role: role)
            teams[index].members.append(newMember)
            saveTeams()
        }
    }
    
    func removeMember(teamId: UUID, memberId: UUID) {
        if let teamIndex = teams.firstIndex(where: { $0.id == teamId }) {
            teams[teamIndex].members.removeAll { $0.id == memberId }
            saveTeams()
        }
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