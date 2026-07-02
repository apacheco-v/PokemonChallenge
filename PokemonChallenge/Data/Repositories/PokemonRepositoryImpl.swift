import Foundation

final class PokemonRepositoryImpl: PokemonListRepositoryProtocol, PokemonDetailRepositoryProtocol {
    private let networkClient: NetworkClientProtocol
    private let persistenceClient: PersistenceClientProtocol

    init(networkClient: NetworkClientProtocol, persistenceClient: PersistenceClientProtocol) {
        self.networkClient = networkClient
        self.persistenceClient = persistenceClient
    }

    func fetchPokemonList(offset: Int, limit: Int) async throws -> FetchResult<[Pokemon]> {
        let cacheKey = "pokemon_list_\(offset)_\(limit)"

        do {
            let dto: PokemonListResponseDTO = try await networkClient.request(
                PokemonEndpoint.list(offset: offset, limit: limit)
            )
            try? await persistenceClient.cache(dto, forKey: cacheKey)
            return FetchResult(value: try PokemonListResponseMapper.map(dto), isFromCache: false)
        } catch {
            guard let cached: PokemonListResponseDTO = try? await persistenceClient.loadCached(
                PokemonListResponseDTO.self, forKey: cacheKey, maxAge: CacheConstants.ttl
            ) else {
                throw error
            }
            return FetchResult(value: try PokemonListResponseMapper.map(cached), isFromCache: true)
        }
    }

    func fetchPokemonDetail(id: Int) async throws -> FetchResult<PokemonDetail> {
        let cacheKey = "pokemon_detail_\(id)"

        do {
            let dto: PokemonDetailDTO = try await networkClient.request(
                PokemonEndpoint.detail(id: id)
            )
            try? await persistenceClient.cache(dto, forKey: cacheKey)
            return FetchResult(value: try PokemonDetailMapper.map(dto), isFromCache: false)
        } catch {
            guard let cached: PokemonDetailDTO = try? await persistenceClient.loadCached(
                PokemonDetailDTO.self, forKey: cacheKey, maxAge: CacheConstants.ttl
            ) else {
                throw error
            }
            return FetchResult(value: try PokemonDetailMapper.map(cached), isFromCache: true)
        }
    }
}
