import Testing
@testable import PokemonChallenge

struct UseCaseValidationTests {
    @Test func listUseCase_rejectsNegativeOffset() async {
        let mock = MockPokemonRepository()
        mock.fetchPokemonListHandler = { _, _ in
            FetchResult(value: [], isFromCache: false)
        }
        let useCase = GetPokemonListUseCase(repository: mock)

        await #expect(throws: UseCaseError.invalidOffset) {
            try await useCase.execute(offset: -1, limit: 20)
        }
    }

    @Test func listUseCase_rejectsZeroLimit() async {
        let mock = MockPokemonRepository()
        mock.fetchPokemonListHandler = { _, _ in
            FetchResult(value: [], isFromCache: false)
        }
        let useCase = GetPokemonListUseCase(repository: mock)

        await #expect(throws: UseCaseError.invalidLimit) {
            try await useCase.execute(offset: 0, limit: 0)
        }
    }

    @Test func listUseCase_rejectsLimitAbove100() async {
        let mock = MockPokemonRepository()
        mock.fetchPokemonListHandler = { _, _ in
            FetchResult(value: [], isFromCache: false)
        }
        let useCase = GetPokemonListUseCase(repository: mock)

        await #expect(throws: UseCaseError.invalidLimit) {
            try await useCase.execute(offset: 0, limit: 101)
        }
    }

    @Test func detailUseCase_rejectsNonPositiveId() async {
        let mock = MockPokemonRepository()
        mock.fetchPokemonDetailHandler = { _ in
            FetchResult(value: PokemonDetail(id: 1, name: "", baseExperience: 0, height: 0, weight: 0, types: [], abilities: [], stats: []), isFromCache: false)
        }
        let useCase = GetPokemonDetailUseCase(repository: mock)

        await #expect(throws: UseCaseError.invalidOffset) {
            try await useCase.execute(id: 0)
        }
    }

    @Test func listUseCase_acceptsValidParameters() async throws {
        let mock = MockPokemonRepository()
        mock.fetchPokemonListHandler = { _, _ in
            FetchResult(value: [Pokemon(id: 1, name: "test")], isFromCache: false)
        }
        let useCase = GetPokemonListUseCase(repository: mock)

        let result = try await useCase.execute(offset: 0, limit: 20)
        #expect(result.value.count == 1)
    }

    @Test func detailUseCase_acceptsValidId() async throws {
        let detail = PokemonDetail(id: 1, name: "bulbasaur", baseExperience: 64, height: 7, weight: 69, types: [], abilities: [], stats: [])
        let mock = MockPokemonRepository()
        mock.fetchPokemonDetailHandler = { _ in
            FetchResult(value: detail, isFromCache: false)
        }
        let useCase = GetPokemonDetailUseCase(repository: mock)

        let result = try await useCase.execute(id: 1)
        #expect(result.value.name == "bulbasaur")
    }
}
