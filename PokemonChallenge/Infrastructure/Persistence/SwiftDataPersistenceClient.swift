import Foundation
import SwiftData

final class SwiftDataPersistenceClient: PersistenceClientProtocol {
    private let context: ModelContext
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        context: ModelContext? = nil,
        encoder: JSONEncoder = .init(),
        decoder: JSONDecoder = .init()
    ) {
        let schema = Schema([CachedEntry.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        if let context {
            self.context = context
        } else if let container = try? ModelContainer(for: schema, configurations: [configuration]) {
            self.context = ModelContext(container)
        } else {
            let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            let fallbackContainer = try! ModelContainer(for: schema, configurations: [fallbackConfig])
            self.context = ModelContext(fallbackContainer)
        }

        self.encoder = encoder
        self.decoder = decoder
    }

    func cache<T: Encodable>(_ value: T, forKey key: String) async throws {
        let data = try encoder.encode(value)

        var descriptor = FetchDescriptor<CachedEntry>(
            predicate: #Predicate { $0.key == key }
        )
        descriptor.fetchLimit = 1

        if let existing = try context.fetch(descriptor).first {
            existing.jsonData = data
            existing.createdAt = .now
        } else {
            context.insert(CachedEntry(key: key, jsonData: data))
        }

        try context.save()
    }

    func loadCached<T: Decodable>(_ type: T.Type, forKey key: String, maxAge: TimeInterval? = nil) async throws -> T? {
        var descriptor = FetchDescriptor<CachedEntry>(
            predicate: #Predicate { $0.key == key }
        )
        descriptor.fetchLimit = 1

        guard let entry = try context.fetch(descriptor).first else { return nil }

        if let maxAge, -entry.createdAt.timeIntervalSinceNow > maxAge {
            context.delete(entry)
            try context.save()
            return nil
        }

        return try decoder.decode(T.self, from: entry.jsonData)
    }

    func clearCache() async throws {
        try context.delete(model: CachedEntry.self)
        try context.save()
    }

    func isCached(forKey key: String) async -> Bool {
        var descriptor = FetchDescriptor<CachedEntry>(
            predicate: #Predicate { $0.key == key }
        )
        descriptor.fetchLimit = 1

        return (try? context.fetch(descriptor).first) != nil
    }
}
