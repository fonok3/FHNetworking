//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

import Foundation

/// Conversion to `URLRequest`
extension FHNetworkRequest {
    /// Creates `URLRequest` request against base url
    ///
    /// - Parameters:
    ///     - baseUrl: base url to which the request path is relatively
    /// - Returns: Corresponding `URLRequest`.`
    func request(with baseUrl: String) -> URLRequest? {
        guard let baseURL = URL(string: baseUrl) else {
            return nil
        }

        var urlComponents = URLComponents()
        urlComponents.scheme = baseURL.scheme
        urlComponents.host = baseURL.host
        urlComponents.path = baseURL.path + path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        urlComponents.queryItems = parameters

        guard let finalURL = urlComponents.url else {
            return nil
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body

        return request
    }
}
