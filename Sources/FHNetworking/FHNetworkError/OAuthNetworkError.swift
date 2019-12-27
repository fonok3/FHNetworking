//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

/// Errors, which occur while authenticating `OAuthNetworkService`.
public enum OAuthNetworkError: Error {
    /// Error while retrieving *Request Token*.
    case getRequestTokenFailed(FHNetworkError?)
    /// Error while authenticating the *Request Token*.
    case authorizationFailed(FHNetworkError?)
    /// Error retrieving *Access Token*
    case getAccessTokenFailed(FHNetworkError?)

    /// Readable description of error
    public var localizedDescription: String {
        switch self {
        case let .getRequestTokenFailed(error):
            return "Error getting Reqeust Token:\n" + (error?.localizedDescription ?? "")
        case let .authorizationFailed(error):
            return "Error authorizing token:\n" + (error?.localizedDescription ?? "")
        case let .getAccessTokenFailed(error):
            return "Error getting Access Token:\n" + (error?.localizedDescription ?? "")
        }
    }
}
