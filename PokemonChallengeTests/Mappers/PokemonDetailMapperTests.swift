import Testing
@testable import PokemonChallenge

struct PokemonDetailMapperTests {
    @Test func map_withValidDetail_returnsPokemonDetail() throws {
        let dto = PokemonDetailDTO(
            id: 25,
            name: "pikachu",
            baseExperience: 112,
            height: 4,
            weight: 60,
            types: [PokemonTypeDTO(slot: 1, type: NamedAPIResourceDTO(name: "electric", url: ""))],
            abilities: [
                PokemonAbilityDTO(ability: NamedAPIResourceDTO(name: "static", url: ""), isHidden: false, slot: 1),
                PokemonAbilityDTO(ability: NamedAPIResourceDTO(name: "lightning-rod", url: ""), isHidden: true, slot: 2),
            ],
            stats: [
                PokemonStatDTO(baseStat: 55, stat: NamedAPIResourceDTO(name: "hp", url: "")),
                PokemonStatDTO(baseStat: 90, stat: NamedAPIResourceDTO(name: "speed", url: "")),
            ]
        )

        let result = try PokemonDetailMapper.map(dto)

        #expect(result.id == 25)
        #expect(result.name == "pikachu")
        #expect(result.baseExperience == 112)
        #expect(result.height == 4)
        #expect(result.weight == 60)
        #expect(result.types.count == 1)
        #expect(result.types.first?.name == "electric")
        #expect(result.abilities.count == 2)
        #expect(result.abilities.first?.name == "static")
        #expect(result.abilities.first?.isHidden == false)
        #expect(result.abilities.last?.isHidden == true)
        #expect(result.stats.count == 2)
        #expect(result.stats.first?.name == "hp")
        #expect(result.stats.first?.baseStat == 55)
    }

    @Test func map_withNilBaseExperience_throwsError() {
        let dto = PokemonDetailDTO(
            id: 1,
            name: "bulbasaur",
            baseExperience: nil,
            height: 7,
            weight: 69,
            types: [],
            abilities: [],
            stats: []
        )

        #expect(throws: MappingError.self) {
            try PokemonDetailMapper.map(dto)
        }
    }
}
