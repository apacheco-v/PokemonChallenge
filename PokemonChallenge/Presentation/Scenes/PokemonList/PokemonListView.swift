import SwiftUI

struct PokemonListView: View {
    @StateObject private var viewModel: PokemonListViewModel
    @State private var path: [PokemonRoute] = []
    @State private var rawSearchText = ""
    private let getPokemonDetailUseCase: GetPokemonDetailUseCase

    init(viewModel: PokemonListViewModel, detailUseCase: GetPokemonDetailUseCase) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.getPokemonDetailUseCase = detailUseCase
    }

    var body: some View {
        NavigationStack(path: $path) {
            rootView
                .navigationTitle("Pokémon")
                .searchable(text: $rawSearchText, prompt: "Buscar Pokémon...")
                .onChange(of: rawSearchText) { _, newValue in
                    viewModel.setSearchText(newValue)
                }
                .navigationDestination(for: PokemonRoute.self) { route in
                    switch route {
                    case .detail(let id, let name):
                        PokemonDetailView(
                            viewModel: PokemonDetailViewModel(
                                pokemonId: id,
                                getPokemonDetailUseCase: getPokemonDetailUseCase
                            )
                        )
                        .navigationTitle(name.capitalized)
                        .navigationBarTitleDisplayMode(.inline)
                    }
                }
                .refreshable {
                    await viewModel.refresh()
                }
                .onAppear {
                    viewModel.loadNextPage()
                }
        }
    }

    @ViewBuilder
    private var rootView: some View {
        switch viewModel.state {
        case .loading:
            shimmerList
        case .loaded:
            listContent()
        case .empty:
            emptyView
        case .error:
            errorView
        }
    }

    private func listContent() -> some View {
        let displayList = viewModel.filteredPokemons
        let columns = [GridItem(.flexible(), spacing: 4),
                       GridItem(.flexible(), spacing: 4),
                       GridItem(.flexible(), spacing: 4)]

        return ScrollView {
            VStack(spacing: 0) {
                if viewModel.isShowingCachedData {
                    OfflineBanner()
                }

                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(displayList) { pokemon in
                        NavigationLink(value: PokemonRoute.detail(id: pokemon.id, name: pokemon.name)) {
                            PokemonRowView(pokemon: pokemon)
                        }
                        .buttonStyle(.plain)
                        .padding(4)
                        .onAppear {
                            if pokemon == displayList.last && viewModel.searchText.isEmpty {
                                viewModel.loadNextPage()
                            }
                        }
                    }

                    if viewModel.isLoadingMore && viewModel.searchText.isEmpty {
                        HStack {
                            Spacer()
                            ProgressView()
                                .padding(.vertical, 16)
                            Spacer()
                        }
                        .gridCellColumns(3)
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }

    private var shimmerList: some View {
        let columns = [GridItem(.flexible(), spacing: 4),
                       GridItem(.flexible(), spacing: 4),
                       GridItem(.flexible(), spacing: 4)]

        return ScrollView {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(0..<12, id: \.self) { _ in
                    VStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.gray.opacity(0.15))
                            .frame(width: 56, height: 56)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(.gray.opacity(0.15))
                            .frame(height: 12)
                            .frame(width: 72)
                    }
                    .shimmer()
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(4)
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 16)
        }
    }

    private var emptyView: some View {
        ContentUnavailableView(
            "Sin Pokémon",
            systemImage: "tray",
            description: Text("Desliza hacia abajo para recargar.")
        )
    }

    private var errorView: some View {
        ContentUnavailableView(
            "Algo salió mal",
            systemImage: "exclamationmark.triangle",
            description: Text("Revisa tu conexión e inténtalo de nuevo.")
        )
        .overlay(alignment: .bottom) {
            Button("Reintentar") { viewModel.loadNextPage() }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 48)
        }
    }
}
