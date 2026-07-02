@testable import PokemonChallenge

final class MockPokemonRepository: PokemonListRepositoryProtocol, PokemonDetailRepositoryProtocol {
    var fetchPokemonListCallCount = 0
    var fetchPokemonListHandler: ((Int, Int) async throws -> FetchResult<[Pokemon]>)?

    var fetchPokemonDetailCallCount = 0
    var fetchPokemonDetailHandler: ((Int) async throws -> FetchResult<PokemonDetail>)?

    func fetchPokemonList(offset: Int, limit: Int) async throws -> FetchResult<[Pokemon]> {
        fetchPokemonListCallCount += 1
        guard let handler = fetchPokemonListHandler else {
            throw MockError.unexpectedCall
        }
        return try await handler(offset, limit)
    }

    func fetchPokemonDetail(id: Int) async throws -> FetchResult<PokemonDetail> {
        fetchPokemonDetailCallCount += 1
        guard let handler = fetchPokemonDetailHandler else {
            throw MockError.unexpectedCall
        }
        return try await handler(id)
    }
}

enum MockError: Error {
    case unexpectedCall
}
