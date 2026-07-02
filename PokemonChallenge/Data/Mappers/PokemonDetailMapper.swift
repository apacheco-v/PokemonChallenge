import Foundation

enum PokemonDetailMapper {
    static func map(_ dto: PokemonDetailDTO) throws -> PokemonDetail {
        guard let baseExperience = dto.baseExperience else {
            throw MappingError.missingBaseExperience(dto.id)
        }

        let types = dto.types.map { PokemonType(name: $0.type.name) }
        let abilities = dto.abilities.map {
            PokemonAbility(name: $0.ability.name, isHidden: $0.isHidden)
        }
        let stats = dto.stats.map {
            PokemonStat(name: $0.stat.name, baseStat: $0.baseStat)
        }

        return PokemonDetail(
            id: dto.id,
            name: dto.name,
            baseExperience: baseExperience,
            height: dto.height,
            weight: dto.weight,
            types: types,
            abilities: abilities,
            stats: stats
        )
    }
}
