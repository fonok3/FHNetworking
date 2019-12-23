//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

import Foundation

/// Default implementation for network requests
public extension FHNetworkRequest {
    /// Defaults to get method
    var method: HttpMethod {
        return .get
    }

    /// Defaults to no response
    var responseType: Any.Type? {
        return nil
    }

    /// Defaults to no parameters
    var parameters: [URLQueryItem] {
        return [URLQueryItem]()
    }

    /// Defaults to no headers
    var headers: [String: String] {
        return [String: String]()
    }

    /// Defaults to no request body
    var body: Data? {
        return nil
    }
}
