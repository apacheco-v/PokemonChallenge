import Foundation

struct GetPokemonListUseCase {
    private let repository: PokemonListRepositoryProtocol

    init(repository: PokemonListRepositoryProtocol) {
        self.repository = repository
    }

    func execute(offset: Int, limit: Int) async throws -> FetchResult<[Pokemon]> {
        try await repository.fetchPokemonList(offset: offset, limit: limit)
    }
}
