import Foundation

protocol PersistenceClientProtocol {
    func cache<T: Encodable>(_ value: T, forKey key: String) async throws
    func loadCached<T: Decodable>(_ type: T.Type, forKey key: String, maxAge: TimeInterval?) async throws -> T?
    func clearCache() async throws
    func isCached(forKey key: String) async -> Bool
}
