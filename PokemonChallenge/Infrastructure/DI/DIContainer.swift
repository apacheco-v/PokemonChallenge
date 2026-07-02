import Foundation

final class DIContainer {
    let networkClient: NetworkClientProtocol
    let persistenceClient: PersistenceClientProtocol
    let pokemonRepository: PokemonListRepositoryProtocol & PokemonDetailRepositoryProtocol
    let getPokemonListUseCase: GetPokemonListUseCase
    let getPokemonDetailUseCase: GetPokemonDetailUseCase

    init() {
        networkClient = DefaultNetworkClient()
        persistenceClient = SwiftDataPersistenceClient()
        pokemonRepository = PokemonRepositoryImpl(
            networkClient: networkClient,
            persistenceClient: persistenceClient
        )
        getPokemonListUseCase = GetPokemonListUseCase(repository: pokemonRepository)
        getPokemonDetailUseCase = GetPokemonDetailUseCase(repository: pokemonRepository)
    }
}
