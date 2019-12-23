//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

/// Abstraction for hash algorithms
public protocol HashAlgorithm {
    /// Hashes a string with given key.
    ///
    /// - Parameters:
    ///     - string: The string to be hashed
    ///     - key: The key which is used for hashing
    ///
    /// - Returns: Hashed string
    func hash(string: String, with key: String) -> String

    /// The hashmethod method type
    var hashMethod: HashMethod { get }
}
