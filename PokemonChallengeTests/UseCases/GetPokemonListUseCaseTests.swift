import Testing
@testable import PokemonChallenge

struct GetPokemonListUseCaseTests {
    @Test func execute_callsRepositoryWithCorrectParameters() async throws {
        let mock = MockPokemonRepository()
        var capturedOffset: Int?
        var capturedLimit: Int?
        mock.fetchPokemonListHandler = { offset, limit in
            capturedOffset = offset
            capturedLimit = limit
            return FetchResult(value: [], isFromCache: false)
        }

        let useCase = GetPokemonListUseCase(repository: mock)

        _ = try await useCase.execute(offset: 0, limit: 20)

        #expect(capturedOffset == 0)
        #expect(capturedLimit == 20)
        #expect(mock.fetchPokemonListCallCount == 1)
    }

    @Test func execute_propagatesRepositoryError() async {
        let mock = MockPokemonRepository()
        mock.fetchPokemonListHandler = { _, _ in
            throw NetworkError.timeout
        }

        let useCase = GetPokemonListUseCase(repository: mock)

        await #expect(throws: NetworkError.timeout) {
            try await useCase.execute(offset: 0, limit: 20)
        }
    }

    @Test func execute_returnsRepositoryResults() async throws {
        let mock = MockPokemonRepository()
        mock.fetchPokemonListHandler = { _, _ in
            FetchResult(value: [Pokemon(id: 1, name: "bulbasaur")], isFromCache: false)
        }

        let useCase = GetPokemonListUseCase(repository: mock)

        let result = try await useCase.execute(offset: 0, limit: 20)

        #expect(result.value.count == 1)
        #expect(result.value.first?.name == "bulbasaur")
    }
}
