//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

import Foundation

/// Abtraction of user authorization process
public protocol OAuthAuthoriationHandler {
    /// Authorizes the *OAuth Token* via the given url.
    ///
    /// - Parameters:
    ///     - url: Url for authorizing
    ///     - callbackUrl: Url to be called at the end of the authorization process
    ///     - completion: Response of the authorization
    func authorize(url: URL,
                   callbackUrl: String?,
                   completion: @escaping (Result<(oauthToken: String, oauthVerifier: String), OAuthNetworkError>) -> Void)
}
