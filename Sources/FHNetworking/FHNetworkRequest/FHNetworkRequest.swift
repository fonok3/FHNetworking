//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

import Foundation

/// Simple representation of network requests
public protocol FHNetworkRequest {
    /// Path against base url
    var path: String { get }

    /// Request method
    var method: HttpMethod { get }

    /// Response object type
    var responseType: Any.Type? { get }

    /// URL query parameters
    var parameters: [URLQueryItem] { get }

    /// Request headers
    var headers: [String: String] { get }

    /// Request body
    var body: Data? { get }
}
