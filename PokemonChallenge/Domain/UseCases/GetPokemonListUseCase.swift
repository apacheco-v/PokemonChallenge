import Foundation

struct GetPokemonListUseCase {
    private let repository: PokemonListRepositoryProtocol

    init(repository: PokemonListRepositoryProtocol) {
        self.repository = repository
    }

    func execute(offset: Int, limit: Int) async throws -> FetchResult<[Pokemon]> {
        guard offset >= 0 else { throw UseCaseError.invalidOffset }
        guard limit > 0, limit <= 100 else { throw UseCaseError.invalidLimit }
        return try await repository.fetchPokemonList(offset: offset, limit: limit)
    }
}

enum UseCaseError: Error, LocalizedError {
    case invalidOffset
    case invalidLimit

    var errorDescription: String? {
        switch self {
        case .invalidOffset:
            return "El offset no puede ser negativo"
        case .invalidLimit:
            return "El límite debe estar entre 1 y 100"
        }
    }
}
