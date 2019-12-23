//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

import Foundation

/// Default implementation for `FHNetworkService`.
extension FHNetworkService {
    /// Defaults to unmodified JSON decoder.
    public var decoder: JSONDecoder {
        return JSONDecoder()
    }

    /// Defaults to session with default configuration
    public var session: URLSession {
        return URLSession(configuration: .default)
    }

    /// Executes network request with an optional data response.
    ///
    /// The method converts the given request to an `URLRequest` for requesting with `URLSession`
    ///
    /// - Parameters:
    ///     - request: Network request to be executed
    ///     - completion: Handler for the request result
    /// - Returns: The created url session task
    @discardableResult
    public func request(_ request: FHNetworkRequest,
                        completion: @escaping (Result<Data?, FHNetworkError>) -> Void) -> URLSessionDataTask? {
        guard var urlRequest = request.request(with: self.baseUrl) else {
            completion(.failure(.requestCreationFailed))
            return nil
        }
        if let authorization = authorizationHeader(for: request) {
            urlRequest.addValue(authorization, forHTTPHeaderField: "Authorization")
        }
        return self.request(with: urlRequest, completion: completion)
    }

    /// Executes network request with a JSON response.
    ///
    /// The method converts the given request to an `URLRequest` for requesting with
    ///  `URLSession` and tries to convert the data to the expected response type
    ///
    /// - Parameters:
    ///     - request: Network request to be executed
    ///     - completion: Handler for the request result
    /// - Returns: The created url session task
    @discardableResult
    public func request<T: Decodable>(_ request: FHNetworkRequest,
                                      completion: @escaping (Result<T, FHNetworkError>) -> Void) -> URLSessionDataTask? {
        return self.request(request) { result in
            switch result {
            case let .success(data):
                let data = data ?? "".data(using: .utf8)!

                do {
                    completion(.success(try self.decoder.decode(T.self, from: data)))
                } catch {
                    completion(.failure(.decodingError(error as? DecodingError)))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    /// Executes the `URLRequest` as data task against the service's session.
    ///
    /// - Parameters:
    ///     - request: `URLRequest` to be executed
    ///     - completion: Handler for the request result
    /// - Returns: The created url session task
    private func request(with request: URLRequest,
                         completion: @escaping (Result<Data?, FHNetworkError>) -> Void) -> URLSessionDataTask? {
        let dataTask = session.dataTask(with: request) { data, response, error in
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            let statusType = HttpStatus(with: statusCode, error: error)

            switch statusType {
            case .success:
                completion(.success(data))
            default:
                completion(.failure(.httpError(statusType, data)))
            }
        }

        dataTask.resume()
        return dataTask
    }

    /// Defaults to no authorization header
    public func authorizationHeader(for _: FHNetworkRequest) -> String? {
        return nil
    }

    /// Combines base url and path
    ///
    /// - Parameters:
    ///     - path: Path of ressource
    /// - Returns: `URL` with combined url string
    public func urlFor(path: String) -> URL? {
        return URL(string: baseUrl + path)
    }
}
