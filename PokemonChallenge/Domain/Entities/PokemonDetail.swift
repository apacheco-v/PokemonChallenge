import Foundation

struct PokemonDetail: Identifiable, Hashable {
    let id: Int
    let name: String
    let baseExperience: Int
    let height: Int
    let weight: Int
    let types: [PokemonType]
    let abilities: [PokemonAbility]
    let stats: [PokemonStat]
}
