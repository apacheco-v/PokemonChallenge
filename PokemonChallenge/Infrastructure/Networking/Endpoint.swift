import Foundation

protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryParameters: [String: String]? { get }
    var body: Encodable? { get }
}

extension Endpoint {
    var headers: [String: String]? { nil }
    var queryParameters: [String: String]? { nil }
    var body: Encodable? { nil }
}
