//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

import Foundation

extension Array where Element == URLQueryItem {
    /// Returns the query items as url encoded strings
    var urlEncoded: String {
        return sorted { $0.name < $1.name }
            .compactMap { $0.urlEncoded }
            .joined(separator: "&")
    }

    /// Returns the query item as header encoded string
    var headerEncoded: String {
        return sorted { $0.name < $1.name }
            .compactMap { $0.urlEncoded }
            .joined(separator: ", ")
    }
}
