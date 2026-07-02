import Foundation
import SwiftData

@Model
final class CachedEntry {
    @Attribute(.unique) var key: String
    var jsonData: Data
    var createdAt: Date

    init(key: String, jsonData: Data, createdAt: Date = .now) {
        self.key = key
        self.jsonData = jsonData
        self.createdAt = createdAt
    }
}
