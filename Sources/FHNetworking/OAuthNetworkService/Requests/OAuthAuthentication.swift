//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

import Foundation

/// Model for all attributes needed for *OAuth* Authorization.
public struct OAuthAuthentication {
    private let fullPath: String
    private let method: HttpMethod
    private let consumerToken: String
    private let consumerTokenSecret: String
    private let token: String?
    private let tokenSecret: String?
    private let verifier: String?
    private let nonce: String
    private let version: OAuthVersion
    private let hashAlgorithm: HashAlgorithm
    private let timestamp: String
    private let queryParameters: [URLQueryItem]

    /// Initializes the OAuthAuthentication with at least *Full Request Path*, *HTTP
    ///  Method*, *Consumer Token* and *Consumer Token Secret*.
    ///
    /// - Parameters:
    ///     - fullPath: The *path* of the route with *baseUrl* included.
    ///     - method: The HTTP Method.
    ///     - consumerToken: The *OAuth Consumer Token*.
    ///     - consumerTokenSecret: The *OAuth Consumer Token Secret*.
    ///     - token: The *OAuth Token*.
    ///     - tokenSecret: The *OAuth Token Secret*.
    ///     - verifier: The *OAuth Verifier*.
    ///     - nonce: A random string.
    ///     - hashAlgorithm: The used *Hash Algorithm* used for generating the *OAuth Verifier*.
    ///     - version: The user *OAuth Version*.
    ///     - timestamp: The current timestamp.
    public init(fullPath: String, method: HttpMethod,
                consumerToken: String, consumerTokenSecret: String,
                token: String? = nil, tokenSecret: String? = nil,
                verifier: String? = nil, nonce: String = UUID().uuidString,
                hashAlgorithm: HashAlgorithm = SHA1HashAlgorithm(), version: OAuthVersion = .v1,
                timestamp: String = String(Date().timeIntervalSince1970),
                queryParameters: [URLQueryItem] = [URLQueryItem]()) {
        self.fullPath = fullPath
        self.method = method
        self.consumerToken = consumerToken
        self.consumerTokenSecret = consumerTokenSecret
        self.token = token
        self.tokenSecret = tokenSecret
        self.verifier = verifier
        self.nonce = nonce
        self.version = version
        self.hashAlgorithm = hashAlgorithm
        self.timestamp = timestamp
        self.queryParameters = queryParameters
    }

    /// Signing key for generating `OAuth Signature`
    private var signingKey: String {
        return consumerTokenSecret + "&" + (tokenSecret ?? "")
    }

    /// Parameters to be encoded for `OAuth Signature`
    private var baseParams: [URLQueryItem] {
        var params = [
            URLQueryItem(name: "oauth_consumer_key", value: self.consumerToken),
            URLQueryItem(name: "oauth_signature_method", value: self.hashAlgorithm.hashMethod.rawValue),
            URLQueryItem(name: "oauth_timestamp", value: self.timestamp),
            URLQueryItem(name: "oauth_nonce", value: self.nonce),
            URLQueryItem(name: "oauth_version", value: self.version.rawValue),
        ]
        if let token = self.token {
            params.append(URLQueryItem(name: "oauth_token", value: token))
        }
        if let verifier = self.verifier {
            params.append(URLQueryItem(name: "oauth_verifier", value: verifier))
        }
        return params
    }

    /// URL encoded *OAuth Signature*
    private var signatureBaseString: String {
        let methodString = method.rawValue.addingPercentEncoding(withAllowedCharacters: .oauthSignatureAllowed) ?? ""
        let pathString = fullPath.addingPercentEncoding(withAllowedCharacters: .oauthSignatureAllowed) ?? ""
        var params = baseParams
        params.append(contentsOf: queryParameters)
        params.sort { $0.name < $1.name }
        let parameterString = params.urlEncoded.addingPercentEncoding(withAllowedCharacters: .oauthSignatureAllowed) ?? ""
        return [methodString, pathString, parameterString].joined(separator: "&")
    }

    /// The *OAuth Signature* for validating the header.
    ///
    /// The getter hashes the *Signature Base String* with the defined *Hash Algorithm*.
    private var oauthSignature: String {
        return hashAlgorithm.hash(string: signatureBaseString,
                                  with: signingKey)
    }

    /// Authentication parameters for use in the request query parameters.
    ///
    /// The getter adds the *OAuth Signature* to the existing base parameters.
    public var parameters: [URLQueryItem] {
        var tempParams = baseParams
        tempParams.append(URLQueryItem(name: "oauth_signature", value: oauthSignature))
        return tempParams
    }

    /// Authentication String for use in the request header.
    ///
    /// The getter performs header encoding for the parameters.
    public var header: String {
        return "OAuth \(parameters.headerEncoded)"
    }
}
