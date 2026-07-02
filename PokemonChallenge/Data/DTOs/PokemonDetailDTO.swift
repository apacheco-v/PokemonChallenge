import Foundation

struct PokemonDetailDTO: Codable {
    let id: Int
    let name: String
    let baseExperience: Int?
    let height: Int
    let weight: Int
    let types: [PokemonTypeDTO]
    let abilities: [PokemonAbilityDTO]
    let stats: [PokemonStatDTO]

    enum CodingKeys: String, CodingKey {
        case id, name, height, weight, types, abilities, stats
        case baseExperience = "base_experience"
    }
}

struct PokemonTypeDTO: Codable {
    let slot: Int
    let type: NamedAPIResourceDTO
}

struct PokemonAbilityDTO: Codable {
    let ability: NamedAPIResourceDTO
    let isHidden: Bool
    let slot: Int

    enum CodingKeys: String, CodingKey {
        case ability, slot
        case isHidden = "is_hidden"
    }
}

struct PokemonStatDTO: Codable {
    let baseStat: Int
    let stat: NamedAPIResourceDTO

    enum CodingKeys: String, CodingKey {
        case baseStat = "base_stat"
        case stat
    }
}
