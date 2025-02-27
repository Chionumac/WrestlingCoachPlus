import Foundation

class UserDefaultsPracticeService: PracticeServiceProtocol {
    private let storageKey = "savedPractices"
    private var _lastError: Error?
    
    var lastError: Error? {
        get { _lastError }
    }
    
    func save(_ practice: Practice) throws {
        var practices = load()
        practices.removeAll { Calendar.current.isDate($0.date, inSameDayAs: practice.date) }
        practices.append(practice)
        
        do {
            let encoded = try JSONEncoder().encode(practices)
            UserDefaults.standard.set(encoded, forKey: storageKey)
        } catch {
            _lastError = PracticeServiceError.saveFailed
            throw PracticeServiceError.saveFailed
        }
    }
    
    func load() -> [Practice] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return []
        }
        
        do {
            return try JSONDecoder().decode([Practice].self, from: data)
        } catch {
            _lastError = PracticeServiceError.loadFailed
            return []
        }
    }
    
    func delete(for date: Date) {
        var practices = load()
        practices.removeAll { Calendar.current.isDate($0.date, inSameDayAs: date) }
        
        do {
            let encoded = try JSONEncoder().encode(practices)
            UserDefaults.standard.set(encoded, forKey: storageKey)
        } catch {
            _lastError = PracticeServiceError.deleteFailed
        }
    }
    
    func getPractice(for date: Date) -> Practice? {
        load().first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func saveMultiple(_ practices: [Practice]) throws {
        for practice in practices {
            try save(practice)
        }
    }
    
    func deleteAll() throws {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
    
    func validate(_ practice: Practice) -> Bool {
        practice.isValid
    }
} 