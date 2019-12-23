//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

import Foundation

/// Hash alorithm which just returns the string it self
public class PlainTextHashAlgorithm: HashAlgorithm {
    /// No further initialization needed
    public init() {}

    /// Hash implementation without modification of the string
    ///
    /// - Parameters:
    ///     - string: The string to be returned
    ///
    /// - Returns: The string it self
    public func hash(string: String, with _: String) -> String {
        return string
    }

    /// Plaintext hash method
    public var hashMethod: HashMethod {
        return .plaintext
    }
}
