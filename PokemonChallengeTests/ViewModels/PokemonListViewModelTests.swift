import Testing
@testable import PokemonChallenge

@MainActor
struct PokemonListViewModelTests {
    private func makeSut(
        mockHandler: @escaping (Int, Int) async throws -> FetchResult<[Pokemon]>
    ) -> (viewModel: PokemonListViewModel, mock: MockPokemonRepository) {
        let mock = MockPokemonRepository()
        mock.fetchPokemonListHandler = mockHandler
        let useCase = GetPokemonListUseCase(repository: mock)
        let viewModel = PokemonListViewModel(getPokemonListUseCase: useCase)
        return (viewModel, mock)
    }

    private func waitUntilIdle(_ viewModel: PokemonListViewModel) async {
        while viewModel.isLoadingMore {
            await Task.sleep(10_000_000)
        }
    }

    @Test func loadNextPage_success_transitionsToLoaded() async {
        let (viewModel, _) = makeSut { _, _ in
            FetchResult(value: [Pokemon(id: 1, name: "bulbasaur"), Pokemon(id: 4, name: "charmander")], isFromCache: false)
        }

        viewModel.loadNextPage()
        await waitUntilIdle(viewModel)

        if case let .loaded(pokemons) = viewModel.state {
            #expect(pokemons.count == 2)
            #expect(pokemons.first?.name == "bulbasaur")
        } else {
            Issue.record("Expected .loaded, got \(viewModel.state)")
        }
    }

    @Test func loadNextPage_error_setsErrorState() async {
        let (viewModel, _) = makeSut { _, _ in
            throw NetworkError.noInternet
        }

        viewModel.loadNextPage()
        await waitUntilIdle(viewModel)

        if case .error = viewModel.state {
            // expected
        } else {
            Issue.record("Expected .error, got \(viewModel.state)")
        }
    }

    @Test func loadNextPage_emptyList_setsEmptyState() async {
        let (viewModel, _) = makeSut { _, _ in
            FetchResult(value: [], isFromCache: false)
        }

        viewModel.loadNextPage()
        await waitUntilIdle(viewModel)

        #expect(viewModel.state == .empty)
    }

    @Test func refresh_resetsStateAndLoadsFreshData() async {
        let (viewModel, mock) = makeSut { _, _ in
            FetchResult(value: [Pokemon(id: 1, name: "bulbasaur")], isFromCache: false)
        }

        viewModel.loadNextPage()
        await waitUntilIdle(viewModel)

        mock.fetchPokemonListHandler = { _, _ in
            FetchResult(value: [Pokemon(id: 7, name: "squirtle")], isFromCache: false)
        }

        await viewModel.refresh()

        #expect(viewModel.isLoadingMore == false)
        if case let .loaded(pokemons) = viewModel.state {
            #expect(pokemons.count == 1)
            #expect(pokemons.first?.name == "squirtle")
        } else {
            Issue.record("Expected .loaded, got \(viewModel.state)")
        }
    }

    @Test func pagination_accumulatesPokemonsAcrossPages() async {
        let (viewModel, mock) = makeSut { offset, limit in
            FetchResult(value: (0..<limit).map { Pokemon(id: offset + $0, name: "pokemon-\(offset + $0)") }, isFromCache: false)
        }

        viewModel.loadNextPage()
        await waitUntilIdle(viewModel)

        if case let .loaded(pokemons) = viewModel.state {
            #expect(pokemons.count == 20)
        } else {
            Issue.record("Expected .loaded after page 1")
        }

        viewModel.loadNextPage()
        await waitUntilIdle(viewModel)

        if case let .loaded(pokemons) = viewModel.state {
            #expect(pokemons.count == 40)
        } else {
            Issue.record("Expected .loaded after page 2")
        }

        #expect(mock.fetchPokemonListCallCount == 2)
    }

    @Test func loadNextPage_preventsConcurrentCalls() async {
        let (viewModel, mock) = makeSut { _, _ in
            await Task.sleep(100_000_000)
            return FetchResult(value: [Pokemon(id: 1, name: "bulbasaur")], isFromCache: false)
        }

        viewModel.loadNextPage()
        viewModel.loadNextPage()

        await waitUntilIdle(viewModel)

        #expect(mock.fetchPokemonListCallCount == 1, "Expected only 1 call, got \(mock.fetchPokemonListCallCount)")
    }

    @Test func paginationError_setsErrorWhenCachedDataExists() async {
        let (viewModel, mock) = makeSut { offset, limit in
            if offset == 0 {
                return FetchResult(value: (0..<limit).map { Pokemon(id: $0, name: "pokemon-\($0)") }, isFromCache: false)
            }
            throw NetworkError.noInternet
        }

        viewModel.loadNextPage()
        await waitUntilIdle(viewModel)

        #expect(viewModel.paginationError == nil)

        viewModel.loadNextPage()
        await waitUntilIdle(viewModel)

        #expect(viewModel.paginationError != nil)
    }
}
