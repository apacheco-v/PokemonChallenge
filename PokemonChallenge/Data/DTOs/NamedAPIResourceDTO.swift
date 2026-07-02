import Foundation

struct NamedAPIResourceDTO: Codable {
    let name: String
    let url: String
}

extension NamedAPIResourceDTO {
    var id: Int? {
        let trimmed = url.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let lastSegment = trimmed.split(separator: "/").last else { return nil }
        return Int(lastSegment)
    }
}
