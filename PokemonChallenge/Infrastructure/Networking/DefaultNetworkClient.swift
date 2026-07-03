import Foundation
import OSLog

final class DefaultNetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let logger = Logger(subsystem: "com.pokemonchallenge", category: "network")

    init(session: URLSession = .shared, decoder: JSONDecoder = .init()) {
        self.session = session
        self.decoder = decoder
    }

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let data = try await request(endpoint)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.parsing(error)
        }
    }

    func request(_ endpoint: Endpoint) async throws -> Data {
        let maxRetries = 2
        var lastError: Error?

        for attempt in 0...maxRetries {
            do {
                return try await performRequest(endpoint)
            } catch let error as NetworkError {
                switch error {
                case .timeout, .unknown:
                    lastError = error
                    if attempt < maxRetries {
                        let delay = Double(attempt + 1) * 1.0
                        logger.notice("Retrying after \(error.localizedDescription) (attempt \(attempt + 1)/\(maxRetries))")
                        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    }
                default:
                    throw error
                }
            } catch {
                throw error
            }
        }

        throw lastError ?? NetworkError.timeout
    }

    private func performRequest(_ endpoint: Endpoint) async throws -> Data {
        guard var components = URLComponents(string: endpoint.baseURL + endpoint.path) else {
            throw NetworkError.invalidURL
        }

        if let queryParameters = endpoint.queryParameters {
            components.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.allHTTPHeaderFields = endpoint.headers
        urlRequest.timeoutInterval = APIConstants.defaultTimeout

        if let body = endpoint.body {
            do {
                urlRequest.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw NetworkError.encoding(error)
            }
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let error as URLError {
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw NetworkError.noInternet
            case .timedOut:
                throw NetworkError.timeout
            default:
                throw NetworkError.unknown(error)
            }
        } catch {
            throw NetworkError.unknown(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown(URLError(.badServerResponse))
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            logger.warning("HTTP \(httpResponse.statusCode) for \(endpoint.method.rawValue) \(url.absoluteString)")
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
        }

        logger.debug("\(endpoint.method.rawValue) \(url.absoluteString) → \(httpResponse.statusCode)")
        return data
    }
}
