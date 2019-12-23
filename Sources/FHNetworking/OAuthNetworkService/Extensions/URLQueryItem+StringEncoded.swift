//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

import Foundation

extension URLQueryItem {
    /// Returns the query item as url encoded string
    var urlEncoded: String? {
        return value != nil ? description : nil
    }
}
