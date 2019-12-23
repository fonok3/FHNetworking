//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

import Foundation

/// Abstraction for executing network requests
public protocol FHNetworkService {
    /// Base Url of the service
    var baseUrl: String { get }
    /// Configured session
    var session: URLSession { get }
    /// JSON Decoder for converting json responses
    var decoder: JSONDecoder { get }

    /// Executes network request with an optional data response
    ///
    /// - Parameters:
    ///     - request: Network request to be executed
    ///     - completion: Handler for the request result
    /// - Returns: The created url session task
    @discardableResult func request(_ request: FHNetworkRequest,
                                    completion: @escaping (Result<Data?, FHNetworkError>) -> Void)
        -> URLSessionDataTask?

    /// Executes network request with JSON response
    ///
    /// - Parameters:
    ///     - request: Network request to be executed
    ///     - completion: Handler for the request result
    /// - Returns: The created url session task
    @discardableResult func request<T: Decodable>(_ request: FHNetworkRequest,
                                                  completion: @escaping (Result<T, FHNetworkError>) -> Void)
        -> URLSessionDataTask?

    /// Creates authorization header for a network request
    ///
    /// - Parameters:
    ///     - request: network request to be authenticated
    /// - Returns: Authorization header string
    func authorizationHeader(for request: FHNetworkRequest) -> String?
}
