import Foundation
import Testing
@testable import PokemonChallenge

struct NetworkErrorTests {
    @Test func invalidURL_description_isSpanish() {
        #expect(NetworkError.invalidURL.errorDescription == "URL inválida")
    }

    @Test func noInternet_description_isSpanish() {
        #expect(NetworkError.noInternet.errorDescription == "Sin conexión a Internet")
    }

    @Test func timeout_description_isSpanish() {
        #expect(NetworkError.timeout.errorDescription == "La solicitud tardó demasiado")
    }

    @Test func httpError_description_includesStatusCode() {
        let error = NetworkError.httpError(statusCode: 404, data: nil)
        #expect(error.errorDescription == "Error del servidor (404)")
    }

    @Test func equatable_invalidURL() {
        #expect(NetworkError.invalidURL == NetworkError.invalidURL)
        #expect(NetworkError.invalidURL != NetworkError.noInternet)
    }

    @Test func equatable_httpError_byStatusCode() {
        let error404a = NetworkError.httpError(statusCode: 404, data: nil)
        let error404b = NetworkError.httpError(statusCode: 404, data: Data())
        let error500 = NetworkError.httpError(statusCode: 500, data: nil)
        #expect(error404a == error404b)
        #expect(error404a != error500)
    }

    @Test func equatable_timeout() {
        #expect(NetworkError.timeout == NetworkError.timeout)
    }
}
