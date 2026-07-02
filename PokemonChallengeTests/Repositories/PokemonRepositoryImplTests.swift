import Foundation
import Testing
@testable import PokemonChallenge

private final class MockNetworkClient: NetworkClientProtocol {
    var requestHandler: ((Endpoint) async throws -> Data)?
    var requestCount = 0

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        requestCount += 1
        guard let handler = requestHandler else { throw MockError.unexpectedCall }
        let data = try await handler(endpoint)
        return try JSONDecoder().decode(T.self, from: data)
    }

    func request(_ endpoint: Endpoint) async throws -> Data {
        requestCount += 1
        guard let handler = requestHandler else { throw MockError.unexpectedCall }
        return try await handler(endpoint)
    }
}

private final class MockPersistenceClient: PersistenceClientProtocol {
    var storage: [String: Data] = [:]
    var cacheCallCount = 0
    var loadCallCount = 0

    func cache<T: Encodable>(_ value: T, forKey key: String) async throws {
        cacheCallCount += 1
        storage[key] = try JSONEncoder().encode(value)
    }

    func loadCached<T: Decodable>(_ type: T.Type, forKey key: String, maxAge: TimeInterval? = nil) async throws -> T? {
        loadCallCount += 1
        guard let data = storage[key] else { return nil }
        return try JSONDecoder().decode(T.self, from: data)
    }

    func clearCache() async throws {
        storage.removeAll()
    }

    func isCached(forKey key: String) async -> Bool {
        storage[key] != nil
    }
}

private extension PokemonListResponseDTO {
    static func mock(ids: [Int]) -> PokemonListResponseDTO {
        PokemonListResponseDTO(
            count: ids.count,
            results: ids.map { id in
                NamedAPIResourceDTO(name: "pokemon-\(id)", url: "https://pokeapi.co/api/v2/pokemon/\(id)/")
            }
        )
    }
}

private extension PokemonDetailDTO {
    static func mock(id: Int) -> PokemonDetailDTO {
        PokemonDetailDTO(
            id: id,
            name: "pokemon-\(id)",
            baseExperience: 50,
            height: 10,
            weight: 100,
            types: [PokemonTypeDTO(slot: 1, type: NamedAPIResourceDTO(name: "grass", url: ""))],
            abilities: [PokemonAbilityDTO(ability: NamedAPIResourceDTO(name: "overgrow", url: ""), isHidden: false, slot: 1)],
            stats: [PokemonStatDTO(baseStat: 45, stat: NamedAPIResourceDTO(name: "hp", url: ""))]
        )
    }
}

@MainActor
struct PokemonRepositoryImplTests {
    @Test func fetchPokemonList_networkFirst_returnsMappedPokemons() async throws {
        let network = MockNetworkClient()
        let persistence = MockPersistenceClient()
        let repository = PokemonRepositoryImpl(networkClient: network, persistenceClient: persistence)

        network.requestHandler = { _ in
            let dto = PokemonListResponseDTO.mock(ids: [1, 4, 7])
            return try JSONEncoder().encode(dto)
        }

        let result = try await repository.fetchPokemonList(offset: 0, limit: 20)

        #expect(result.value.count == 3)
        #expect(result.value.first?.id == 1)
        #expect(result.value.first?.name == "pokemon-1")
        #expect(result.isFromCache == false)
        #expect(network.requestCount == 1)
    }

    @Test func fetchPokemonList_networkSuccess_cachesData() async throws {
        let network = MockNetworkClient()
        let persistence = MockPersistenceClient()
        let repository = PokemonRepositoryImpl(networkClient: network, persistenceClient: persistence)

        network.requestHandler = { _ in
            let dto = PokemonListResponseDTO.mock(ids: [1, 4, 7])
            return try JSONEncoder().encode(dto)
        }

        _ = try await repository.fetchPokemonList(offset: 0, limit: 20)

        #expect(persistence.cacheCallCount == 1)
        let cached: PokemonListResponseDTO? = try await persistence.loadCached(PokemonListResponseDTO.self, forKey: "pokemon_list_0_20")
        #expect(cached != nil)
        #expect(cached?.results.count == 3)
    }

    @Test func fetchPokemonList_networkFails_returnsCachedData() async throws {
        let network = MockNetworkClient()
        let persistence = MockPersistenceClient()
        let repository = PokemonRepositoryImpl(networkClient: network, persistenceClient: persistence)

        let dto = PokemonListResponseDTO.mock(ids: [1, 4, 7])
        try await persistence.cache(dto, forKey: "pokemon_list_0_20")

        network.requestHandler = { _ in
            throw NetworkError.noInternet
        }

        let result = try await repository.fetchPokemonList(offset: 0, limit: 20)

        #expect(result.value.count == 3)
        #expect(result.isFromCache == true)
        #expect(persistence.loadCallCount == 1)
    }

    @Test func fetchPokemonList_bothFail_propagatesError() async {
        let network = MockNetworkClient()
        let persistence = MockPersistenceClient()
        let repository = PokemonRepositoryImpl(networkClient: network, persistenceClient: persistence)

        network.requestHandler = { _ in
            throw NetworkError.timeout
        }

        await #expect(throws: NetworkError.timeout) {
            try await repository.fetchPokemonList(offset: 0, limit: 20)
        }
    }

    @Test func fetchPokemonDetail_networkFirst_returnsMappedDetail() async throws {
        let network = MockNetworkClient()
        let persistence = MockPersistenceClient()
        let repository = PokemonRepositoryImpl(networkClient: network, persistenceClient: persistence)

        network.requestHandler = { _ in
            let dto = PokemonDetailDTO.mock(id: 1)
            return try JSONEncoder().encode(dto)
        }

        let result = try await repository.fetchPokemonDetail(id: 1)

        #expect(result.value.id == 1)
        #expect(result.value.name == "pokemon-1")
        #expect(result.value.baseExperience == 50)
        #expect(result.isFromCache == false)
        #expect(network.requestCount == 1)
    }

    @Test func fetchPokemonDetail_networkSuccess_cachesData() async throws {
        let network = MockNetworkClient()
        let persistence = MockPersistenceClient()
        let repository = PokemonRepositoryImpl(networkClient: network, persistenceClient: persistence)

        network.requestHandler = { _ in
            let dto = PokemonDetailDTO.mock(id: 1)
            return try JSONEncoder().encode(dto)
        }

        _ = try await repository.fetchPokemonDetail(id: 1)

        #expect(persistence.cacheCallCount == 1)
    }

    @Test func fetchPokemonDetail_networkFails_returnsCachedData() async throws {
        let network = MockNetworkClient()
        let persistence = MockPersistenceClient()
        let repository = PokemonRepositoryImpl(networkClient: network, persistenceClient: persistence)

        let dto = PokemonDetailDTO.mock(id: 1)
        try await persistence.cache(dto, forKey: "pokemon_detail_1")

        network.requestHandler = { _ in
            throw NetworkError.noInternet
        }

        let result = try await repository.fetchPokemonDetail(id: 1)

        #expect(result.value.id == 1)
        #expect(result.isFromCache == true)
        #expect(persistence.loadCallCount == 1)
    }

    @Test func fetchPokemonDetail_bothFail_propagatesError() async {
        let network = MockNetworkClient()
        let persistence = MockPersistenceClient()
        let repository = PokemonRepositoryImpl(networkClient: network, persistenceClient: persistence)

        network.requestHandler = { _ in
            throw NetworkError.timeout
        }

        await #expect(throws: NetworkError.timeout) {
            try await repository.fetchPokemonDetail(id: 1)
        }
    }
}
