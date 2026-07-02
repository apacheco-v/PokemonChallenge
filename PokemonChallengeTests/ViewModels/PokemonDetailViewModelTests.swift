import Testing
@testable import PokemonChallenge

@MainActor
struct PokemonDetailViewModelTests {
    private func makeSut(
        pokemonId: Int = 1,
        mockHandler: @escaping (Int) async throws -> FetchResult<PokemonDetail>
    ) -> (viewModel: PokemonDetailViewModel, mock: MockPokemonRepository) {
        let mock = MockPokemonRepository()
        mock.fetchPokemonDetailHandler = mockHandler
        let useCase = GetPokemonDetailUseCase(repository: mock)
        let viewModel = PokemonDetailViewModel(
            pokemonId: pokemonId,
            getPokemonDetailUseCase: useCase
        )
        return (viewModel, mock)
    }

    private func waitUntilIdle(_ viewModel: PokemonDetailViewModel) async {
        while true {
            if case .loading = viewModel.state {
                await Task.sleep(10_000_000)
            } else {
                break
            }
        }
    }

    @Test func loadDetail_success_transitionsToLoaded() async {
        let detail = PokemonDetail(
            id: 1,
            name: "bulbasaur",
            baseExperience: 64,
            height: 7,
            weight: 69,
            types: [PokemonType(name: "grass"), PokemonType(name: "poison")],
            abilities: [PokemonAbility(name: "overgrow", isHidden: false)],
            stats: [PokemonStat(name: "hp", baseStat: 45)]
        )

        let (viewModel, _) = makeSut { _ in FetchResult(value: detail, isFromCache: false) }

        viewModel.loadDetail()
        await waitUntilIdle(viewModel)

        if case let .loaded(result) = viewModel.state {
            #expect(result.id == 1)
            #expect(result.name == "bulbasaur")
            #expect(result.types.count == 2)
            #expect(result.abilities.count == 1)
            #expect(result.stats.count == 1)
        } else {
            Issue.record("Expected .loaded, got \(viewModel.state)")
        }
    }

    @Test func loadDetail_error_setsErrorState() async {
        let (viewModel, _) = makeSut { _ in
            throw NetworkError.timeout
        }

        viewModel.loadDetail()
        await waitUntilIdle(viewModel)

        if case .error = viewModel.state {
            // expected
        } else {
            Issue.record("Expected .error, got \(viewModel.state)")
        }
    }

    @Test func loadDetail_startsInLoadingState() async {
        let (viewModel, _) = makeSut { _ in
            FetchResult(value: PokemonDetail(
                id: 1,
                name: "bulbasaur",
                baseExperience: 64,
                height: 7,
                weight: 69,
                types: [],
                abilities: [],
                stats: []
            ), isFromCache: false)
        }

        #expect(viewModel.state == .loading)
    }
}
