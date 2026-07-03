import Testing
@testable import PokemonChallenge

struct PokemonEndpointTests {
    @Test func list_path_isPokemon() {
        let endpoint = PokemonEndpoint.list(offset: 0, limit: 20)
        #expect(endpoint.path == "/pokemon")
    }

    @Test func list_queryParameters() {
        let endpoint = PokemonEndpoint.list(offset: 0, limit: 20)
        #expect(endpoint.queryParameters?["offset"] == "0")
        #expect(endpoint.queryParameters?["limit"] == "20")
    }

    @Test func list_method_isGET() {
        let endpoint = PokemonEndpoint.list(offset: 0, limit: 20)
        #expect(endpoint.method == .get)
    }

    @Test func detail_path_includesId() {
        let endpoint = PokemonEndpoint.detail(id: 25)
        #expect(endpoint.path == "/pokemon/25")
    }

    @Test func detail_hasNoQueryParameters() {
        let endpoint = PokemonEndpoint.detail(id: 1)
        #expect(endpoint.queryParameters == nil)
    }

    @Test func detail_method_isGET() {
        let endpoint = PokemonEndpoint.detail(id: 1)
        #expect(endpoint.method == .get)
    }

    @Test func baseURL_usesAPIConstants() {
        let endpoint = PokemonEndpoint.list(offset: 0, limit: 20)
        #expect(endpoint.baseURL == APIConstants.baseURL)
    }
}
