import Foundation

struct PokemonListResponseDTO: Codable {
    let count: Int
    let results: [NamedAPIResourceDTO]
}
