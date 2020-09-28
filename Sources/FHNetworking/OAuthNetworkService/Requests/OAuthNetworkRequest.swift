//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

/// Network requests for *OAuth* authorization.
enum OAuthNetworkRequest: FHNetworkRequest {
    /// Requests the temporary *Request Token*.
    case requestRequestToken(path: String)
    /// Authorizes the temporary *Request Token*.
    case authorizeToken(path: String, token: String, tokenSecret: String)
    /// Requests the permanent *Access Token*.
    case requestAccessToken(path: String, token: String, tokenSecret: String, verifier: String)

    /// *Path* of the requests
    var path: String {
        switch self {
        case let .requestRequestToken(path):
            return path
        case let .authorizeToken(path, _, _):
            return path
        case let .requestAccessToken(path, _, _, _):
            return path
        }
    }

    /// *OAuth Token* of the requests
    var token: String? {
        switch self {
        case .requestRequestToken:
            return nil
        case let .authorizeToken(_, token, _):
            return token
        case let .requestAccessToken(_, token, _, _):
            return token
        }
    }

    /// *OAuth Token Secret* of the requests
    var tokenSecret: String? {
        switch self {
        case .requestRequestToken:
            return nil
        case let .authorizeToken(_, _, tokenSecret):
            return tokenSecret
        case let .requestAccessToken(_, _, tokenSecret, _):
            return tokenSecret
        }
    }

    /// *OAuth Verifier* of the requests
    var verifier: String? {
        switch self {
        case .requestRequestToken:
            return nil
        case .authorizeToken:
            return nil
        case let .requestAccessToken(_, _, _, verifier):
            return verifier
        }
    }

    /// Number of times the request is retried after an error occured
    var numberOfRetries: Int { 3 }
}
