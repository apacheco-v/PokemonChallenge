import Foundation

@MainActor
final class PokemonListViewModel: ObservableObject {
    @Published private(set) var state: ViewState<[Pokemon]> = .loading
    @Published private(set) var isLoadingMore = false
    @Published private(set) var paginationError: String?
    @Published private(set) var isShowingCachedData = false
    @Published var searchText = ""

    private let getPokemonListUseCase: GetPokemonListUseCase
    private let pageSize = PaginationConstants.pageSize

    private var allPokemons: [Pokemon] = []
    private var currentOffset = 0
    private var hasMorePages = true
    private var loadTask: Task<Void, Never>?

    var filteredPokemons: [Pokemon] {
        if searchText.isEmpty {
            return allPokemons
        }
        return allPokemons.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    init(getPokemonListUseCase: GetPokemonListUseCase) {
        self.getPokemonListUseCase = getPokemonListUseCase
    }

    func loadNextPage() {
        guard !isLoadingMore, hasMorePages else { return }

        isLoadingMore = true
        paginationError = nil

        loadTask?.cancel()
        loadTask = Task { [weak self] in
            guard let self else { return }

            do {
                let result = try await getPokemonListUseCase.execute(
                    offset: currentOffset,
                    limit: pageSize
                )

                guard !Task.isCancelled else { return }

                isShowingCachedData = result.isFromCache
                allPokemons.append(contentsOf: result.value)
                currentOffset += pageSize
                hasMorePages = result.value.count == pageSize && result.value.count > 0

                if allPokemons.isEmpty {
                    state = .empty
                } else {
                    state = .loaded(allPokemons)
                }
            } catch {
                guard !Task.isCancelled else { return }
                if allPokemons.isEmpty {
                    state = .error(error.localizedDescription)
                } else {
                    paginationError = error.localizedDescription
                    isShowingCachedData = true
                }
            }

            isLoadingMore = false
        }
    }

    func refresh() async {
        loadTask?.cancel()
        allPokemons = []
        currentOffset = 0
        hasMorePages = true
        paginationError = nil
        isShowingCachedData = false
        searchText = ""
        state = .loading
        isLoadingMore = false
        loadNextPage()
        await loadTask?.value
    }

    func dismissPaginationError() {
        paginationError = nil
    }
}
