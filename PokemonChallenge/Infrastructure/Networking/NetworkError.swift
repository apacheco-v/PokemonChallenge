import Foundation

enum NetworkError: Error, Equatable, LocalizedError {
    case invalidURL
    case noInternet
    case timeout
    case httpError(statusCode: Int, data: Data?)
    case encoding(Error)
    case parsing(Error)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .noInternet:
            return "Sin conexión a Internet"
        case .timeout:
            return "La solicitud tardó demasiado"
        case .httpError(let statusCode, _):
            return "Error del servidor (\(statusCode))"
        case .encoding:
            return "Error al codificar la solicitud"
        case .parsing:
            return "Error al procesar la respuesta"
        case .unknown(let error):
            return error.localizedDescription
        }
    }

    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.noInternet, .noInternet),
             (.timeout, .timeout):
            return true
        case let (.httpError(lhsCode, _), .httpError(rhsCode, _)):
            return lhsCode == rhsCode
        case (.encoding, .encoding),
             (.parsing, .parsing),
             (.unknown, .unknown):
            return true
        default:
            return false
        }
    }
}
