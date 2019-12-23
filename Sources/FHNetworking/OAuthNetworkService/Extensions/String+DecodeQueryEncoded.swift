//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

import Foundation

extension String {
    /// Returns a dictionary containing the decoded key value pairs.
    ///
    /// The Method interprets the string as url encoded query parameters.
    ///
    /// - Returns: Decoded dictionary
    func decodeQueryEncoded() -> [String: String?]? {
        let comp = URLComponents(string: "?" + self)
        guard let items = comp?.queryItems else {
            return [String: String]()
        }

        var dictionary = [String: String]()

        for item in items {
            dictionary[item.name] = item.value
        }

        return dictionary
    }
}
