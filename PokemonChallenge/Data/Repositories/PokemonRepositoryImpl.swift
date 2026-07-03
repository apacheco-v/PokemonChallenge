import Foundation
import OSLog

final class PokemonRepositoryImpl: PokemonListRepositoryProtocol, PokemonDetailRepositoryProtocol {
    private let networkClient: NetworkClientProtocol
    private let persistenceClient: PersistenceClientProtocol
    private let logger = Logger(subsystem: "com.pokemonchallenge", category: "repository")

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
            do {
                try await persistenceClient.cache(dto, forKey: cacheKey)
            } catch {
                logger.error("Failed to cache pokemon list: \(error.localizedDescription)")
            }
            return FetchResult(value: try PokemonListResponseMapper.map(dto), isFromCache: false)
        } catch {
            do {
                guard let cached: PokemonListResponseDTO = try await persistenceClient.loadCached(
                    PokemonListResponseDTO.self, forKey: cacheKey, maxAge: CacheConstants.ttl
                ) else {
                    throw error
                }
                logger.notice("Serving cached pokemon list (network error: \(error.localizedDescription))")
                return FetchResult(value: try PokemonListResponseMapper.map(cached), isFromCache: true)
            } catch {
                logger.error("Both network and cache failed for pokemon list: \(error.localizedDescription)")
                throw error
            }
        }
    }

    func fetchPokemonDetail(id: Int) async throws -> FetchResult<PokemonDetail> {
        let cacheKey = "pokemon_detail_\(id)"

        do {
            let dto: PokemonDetailDTO = try await networkClient.request(
                PokemonEndpoint.detail(id: id)
            )
            do {
                try await persistenceClient.cache(dto, forKey: cacheKey)
            } catch {
                logger.error("Failed to cache pokemon detail \(id): \(error.localizedDescription)")
            }
            return FetchResult(value: try PokemonDetailMapper.map(dto), isFromCache: false)
        } catch {
            do {
                guard let cached: PokemonDetailDTO = try await persistenceClient.loadCached(
                    PokemonDetailDTO.self, forKey: cacheKey, maxAge: CacheConstants.ttl
                ) else {
                    throw error
                }
                logger.notice("Serving cached pokemon detail \(id) (network error: \(error.localizedDescription))")
                return FetchResult(value: try PokemonDetailMapper.map(cached), isFromCache: true)
            } catch {
                logger.error("Both network and cache failed for pokemon detail \(id): \(error.localizedDescription)")
                throw error
            }
        }
    }
}
