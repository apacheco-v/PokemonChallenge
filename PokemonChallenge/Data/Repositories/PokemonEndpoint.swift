import Foundation

enum PokemonEndpoint {
    case list(offset: Int, limit: Int)
    case detail(id: Int)
}

extension PokemonEndpoint: Endpoint {
    var baseURL: String { APIConstants.baseURL }

    var path: String {
        switch self {
        case .list:
            return "/pokemon"
        case .detail(let id):
            return "/pokemon/\(id)"
        }
    }

    var method: HTTPMethod { .get }

    var queryParameters: [String: String]? {
        switch self {
        case .list(let offset, let limit):
            return ["offset": "\(offset)", "limit": "\(limit)"]
        case .detail:
            return nil
        }
    }
}
