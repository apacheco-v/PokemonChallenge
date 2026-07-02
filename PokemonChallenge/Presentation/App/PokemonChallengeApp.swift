import SwiftUI

@main
struct PokemonChallengeApp: App {
    @State private var showSplash = true

    private let container = DIContainer()

    init() {
        configureURLCache()
    }

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreenView()
                    .task {
                        try? await Task.sleep(nanoseconds: 2_000_000_000)
                        showSplash = false
                    }
            } else {
                PokemonListView(
                    viewModel: PokemonListViewModel(
                        getPokemonListUseCase: container.getPokemonListUseCase
                    ),
                    detailUseCase: container.getPokemonDetailUseCase
                )
                .transition(.opacity)
            }
        }
    }

    private func configureURLCache() {
        URLCache.shared = URLCache(
            memoryCapacity: CacheConstants.memoryCapacity,
            diskCapacity: CacheConstants.diskCapacity,
            directory: nil
        )
    }
}
