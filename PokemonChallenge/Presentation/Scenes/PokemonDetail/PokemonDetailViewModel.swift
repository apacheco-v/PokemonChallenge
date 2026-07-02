import Foundation

@MainActor
final class PokemonDetailViewModel: ObservableObject {
    @Published private(set) var state: ViewState<PokemonDetail> = .loading
    @Published private(set) var loadId = UUID()
    @Published private(set) var isShowingCachedData = false

    private let pokemonId: Int
    private let getPokemonDetailUseCase: GetPokemonDetailUseCase
    private var loadTask: Task<Void, Never>?

    init(
        pokemonId: Int,
        getPokemonDetailUseCase: GetPokemonDetailUseCase
    ) {
        self.pokemonId = pokemonId
        self.getPokemonDetailUseCase = getPokemonDetailUseCase
    }

    func loadDetail() {
        loadTask?.cancel()
        state = .loading
        loadId = UUID()

        loadTask = Task { [weak self] in
            guard let self else { return }

            do {
                let result = try await getPokemonDetailUseCase.execute(id: pokemonId)
                guard !Task.isCancelled else { return }
                isShowingCachedData = result.isFromCache
                state = .loaded(result.value)
            } catch {
                guard !Task.isCancelled else { return }
                isShowingCachedData = false
                state = .error(error.localizedDescription)
            }
        }
    }
}
