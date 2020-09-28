//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

import Foundation
import os

/// Default implementation for `FHNetworkService`.
extension FHNetworkService {
    /// Defaults to unmodified JSON decoder.
    public var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }

    /// Executes network request with an optional data response.
    ///
    /// The method converts the given request to an `URLRequest` for requesting with `URLSession`.
    ///
    /// - Parameters:
    ///     - request: Network request to be executed
    ///     - completion: Handler for the request result
    ///     - additionalParameters: Additional query parameters
    /// - Returns: The created url session task
    @discardableResult
    public func request(_ request: FHNetworkRequest,
                        additionalParameters: [URLQueryItem] = [URLQueryItem](),
                        retryCount: Int = 0,
                        completion: @escaping (Result<Data?, FHNetworkError>) -> Void) -> URLSessionDataTask? {
        guard var urlRequest = request.request(with: self.baseUrl, additionalParameters: additionalParameters) else {
            completion(.failure(.requestCreationFailed))
            return nil
        }
        if let authorization = authorizationHeader(for: request) {
            urlRequest.addValue(authorization, forHTTPHeaderField: "Authorization")
        }
        return self.request(with: urlRequest, retryCount: retryCount, completion: completion)
    }

    /// Executes network request with a JSON response.
    ///
    /// The method converts the given request to an `URLRequest` for requesting with
    ///  `URLSession` and tries to convert the data to the expected response type.
    ///
    /// - Parameters:
    ///     - request: Network request to be executed
    ///     - completion: Handler for the request result
    ///     - additionalParameters: Additional query parameters
    /// - Returns: The created url session task
    @discardableResult
    public func request<T: Decodable>(_ request: FHNetworkRequest,
                                      additionalParameters: [URLQueryItem] = [URLQueryItem](),
                                      retryCount: Int = 0,
                                      completion: @escaping (Result<T, FHNetworkError>) -> Void) -> URLSessionDataTask? {
        return self.request(request, additionalParameters: additionalParameters) { result in
            switch result {
            case let .success(data):
                let data = data ?? "".data(using: .utf8)!

                do {
                    completion(.success(try self.decoder.decode(T.self, from: data)))
                } catch {
                    completion(.failure(.decodingError(error as? DecodingError)))
                }
            case let .failure(error):
                guard request.numberOfRetries > retryCount else {
                    return completion(.failure(error))
                }
                if #available(iOS 12.0, *) {
                    os_log(.error, "Retry %d for request: %@, error: %@",
                           (retryCount + 1),
                           request.path,
                           error.localizedDescription)
                }
                self.request(request,
                             additionalParameters: additionalParameters,
                             retryCount: retryCount + 1,
                             completion: completion)
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
                         retryCount _: Int = 0,
                         completion: @escaping (Result<Data?, FHNetworkError>) -> Void) -> URLSessionDataTask? {
        let dataTask = session.dataTask(with: request) { data, response, error in
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            let statusType = HttpStatus(with: statusCode, error: error)

            switch statusType {
            case .success:
                completion(.success(data))
            default:
                completion(.failure(.httpError(statusType, data.utf8Sting)))
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

extension Optional where Wrapped == Data {
    var utf8Sting: String? {
        guard let data = self else { return nil }
        return String(bytes: data, encoding: .utf8)
    }
}
