//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

import Foundation

/// HTTP methods
public enum HttpMethod: String {
    /// Method for getting data
    case get = "GET"
    /// Method for updating data
    case put = "PUT"
    /// Method for creating data
    case post = "POST"
    /// Method for deleting data
    case delete = "DELETE"
}
