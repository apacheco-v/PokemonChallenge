import Foundation

enum PokemonListResponseMapper {
    static func map(_ dto: PokemonListResponseDTO) throws -> [Pokemon] {
        try dto.results.map { resource in
            guard let id = resource.id else {
                throw MappingError.invalidResourceURL(resource.url)
            }
            return Pokemon(id: id, name: resource.name)
        }
    }
}

enum MappingError: Error, LocalizedError {
    case invalidResourceURL(String)
    case missingBaseExperience(Int)

    var errorDescription: String? {
        switch self {
        case let .invalidResourceURL(url):
            return "Invalid resource URL: \(url)"
        case let .missingBaseExperience(id):
            return "Missing base experience for Pokemon ID: \(id)"
        }
    }
}
