import Testing
@testable import PokemonChallenge

struct PokemonListResponseMapperTests {
    @Test func map_withValidResources_returnsPokemons() throws {
        let dto = PokemonListResponseDTO(
            count: 3,
            results: [
                NamedAPIResourceDTO(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/"),
                NamedAPIResourceDTO(name: "ivysaur", url: "https://pokeapi.co/api/v2/pokemon/2/"),
                NamedAPIResourceDTO(name: "venusaur", url: "https://pokeapi.co/api/v2/pokemon/3/"),
            ]
        )

        let result = try PokemonListResponseMapper.map(dto)

        #expect(result.count == 3)
        #expect(result[0].id == 1)
        #expect(result[0].name == "bulbasaur")
        #expect(result[1].id == 2)
        #expect(result[1].name == "ivysaur")
    }

    @Test func map_withInvalidURL_throwsError() {
        let dto = PokemonListResponseDTO(
            count: 1,
            results: [NamedAPIResourceDTO(name: "missing", url: "not-a-url")]
        )

        #expect(throws: MappingError.self) {
            try PokemonListResponseMapper.map(dto)
        }
    }

    @Test func map_withTrailingSlashInURL_parsesCorrectly() throws {
        let dto = PokemonListResponseDTO(
            count: 1,
            results: [NamedAPIResourceDTO(name: "pikachu", url: "https://pokeapi.co/api/v2/pokemon/25/")]
        )

        let result = try PokemonListResponseMapper.map(dto)

        #expect(result.first?.id == 25)
        #expect(result.first?.name == "pikachu")
    }
}
