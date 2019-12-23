//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

import Foundation

/// Possible hash mthods
public enum HashMethod: String {
    /// Plaintext hashing
    case plaintext = "PLAINTEXT"

    /// HMAC-SHA1 hashing
    case hmacSHA1 = "HMAC-SHA1"
}
