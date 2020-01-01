//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

import CommonCrypto
import Foundation

/// HMAC-SHA1 hashing implementation
public class SHA1HashAlgorithm: HashAlgorithm {
    /// No further initialization needed
    public init() {}

    /// Creates HMAC-SHA1 hash with given key.
    ///
    /// - Parameters:
    ///     - string: The string to be hashed
    ///     - key: The key which is used for hashing
    ///
    /// - Returns: HMAC-SHA1 hash
    public func hash(string: String, with key: String) -> String {
        guard let messageData = string.data(using: .utf8),
            let keyData = key.data(using: .utf8) else {
                return ""
        }
        return signature(for: messageData, key: keyData).base64EncodedString()
    }

    /// HMAC-SHA1 hash mehtod
    public var hashMethod: HashMethod {
        return .hmacSHA1
    }

    /// Creates HMAC-SHA1 signature
    private func signature(for data: Data, key: Data) -> Data {
        let signature = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: Int(CC_SHA1_DIGEST_LENGTH))
        defer { signature.deallocate() }

        _ = data.withUnsafeBytes { dataBytes -> UnsafeMutablePointer<CUnsignedChar> in
            key.withUnsafeBytes { keyBytes -> UnsafeMutablePointer<CUnsignedChar> in
                guard let keyAddress = keyBytes.baseAddress, let dataAddress = dataBytes.baseAddress else {
                    return signature
                }
                CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1),
                       keyAddress, key.count,
                       dataAddress, data.count,
                       signature)
                return signature
            }
        }

        return Data(bytes: signature, count: Int(CC_SHA1_DIGEST_LENGTH))
    }
}
