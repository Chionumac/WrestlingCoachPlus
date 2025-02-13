import Foundation

protocol PersistableViewModel {
    associatedtype DataType: Codable
    var storageKey: String { get }
    
    func save(_ data: DataType)
    func load() -> DataType?
}

extension PersistableViewModel {
    func save(_ data: DataType) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    func load() -> DataType? {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return nil }
        return try? JSONDecoder().decode(DataType.self, from: data)
    }
} 