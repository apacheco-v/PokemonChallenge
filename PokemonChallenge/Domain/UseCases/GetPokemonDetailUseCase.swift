import Foundation

struct GetPokemonDetailUseCase {
    private let repository: PokemonDetailRepositoryProtocol

    init(repository: PokemonDetailRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: Int) async throws -> FetchResult<PokemonDetail> {
        try await repository.fetchPokemonDetail(id: id)
    }
}
