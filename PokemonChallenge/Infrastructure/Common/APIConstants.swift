import Foundation

enum APIConstants {
    static let baseURL = "https://pokeapi.co/api/v2"
    static let spriteBaseURL = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon"
    static let defaultTimeout: TimeInterval = 10
}

enum CacheConstants {
    static let memoryCapacity = 50_000_000
    static let diskCapacity = 100_000_000
    static let ttl: TimeInterval = 7 * 24 * 60 * 60
}

enum PaginationConstants {
    static let pageSize = 20
}

enum StatConstants {
    static let maxStatValue: Double = 255
}

enum AnimationConstants {
    static let shimmerDuration: Double = 1.4
    static let shimmerBlurRadius: CGFloat = 24
    static let statBarAnimationDuration: Double = 0.6
}
