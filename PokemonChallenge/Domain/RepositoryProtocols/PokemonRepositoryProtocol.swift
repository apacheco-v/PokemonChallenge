import Foundation

struct FetchResult<T> {
    let value: T
    let isFromCache: Bool
}

protocol PokemonListRepositoryProtocol {
    func fetchPokemonList(offset: Int, limit: Int) async throws -> FetchResult<[Pokemon]>
}

protocol PokemonDetailRepositoryProtocol {
    func fetchPokemonDetail(id: Int) async throws -> FetchResult<PokemonDetail>
}
