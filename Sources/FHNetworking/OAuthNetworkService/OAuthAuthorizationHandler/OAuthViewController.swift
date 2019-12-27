//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

#if os(iOS)
    import AuthenticationServices
    import Foundation
    import SafariServices
    import UIKit

    /// Basic implementation for authentication with OAuth.
    @available(iOS 11.0, *)
    open class OAuthViewController: UIViewController, OAuthAuthoriationHandler {
        /// The current `OAuthNetworkService`.
        open var networkService: OAuthNetworkService?
        /// The used authentication session.
        private var session: FHAuthenticatingSession?

        /// Starts the OAuth Authentication.
        public func startAuthentication() {
            guard let networkService = networkService else {
                fatalError("No network service set.")
            }

            networkService.authorize(with: self) { result in
                DispatchQueue.main.async {
                    self.session?.cancel()
                    self.session = nil
                    self.authorizationCompleted(with: result)
                }
            }
        }

        /// Called when authentication is completed or failed.
        open func authorizationCompleted(
            with _: Result<(accessToken: String, accessTokenSecret: String), OAuthNetworkError>
        ) {}

        /// Called from the network service for user authorization.
        ///
        /// The method performs user authorization with `SFAuthenticationSession` prior to iOS 12 and
        /// with `ASWebAuthenticationSession` above.
        public func authorize(
            url: URL, callbackUrl: String?,
            completion: @escaping (Result<(oauthToken: String, oauthVerifier: String), OAuthNetworkError>) -> Void
        ) {
            DispatchQueue.main.async {
                self.session = self.session(url: url, callbackURLScheme: callbackUrl) { url, _ in

                    guard let url = url,
                        let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                        let parameters = components.queryItems,
                        let token = parameters.first(where: { $0.name == "oauth_token" })?.value,
                        let verifier = parameters.first(where: { $0.name == "oauth_verifier" })?.value else {
                        completion(.failure(.authorizationFailed(nil)))
                        return
                    }

                    completion(.success((oauthToken: token, oauthVerifier: verifier)))
                }
                guard self.session?.start() ?? false else {
                    completion(.failure(.authorizationFailed(.requestCreationFailed)))
                    return
                }
            }
        }

        /// Returns the used session depending on the current OS.
        ///
        /// - Parameters:
        ///     - url: Authentication url.
        ///     - callbackURLScheme: Url to be called at the end.
        ///     - completionHandler: Handler to be called at the end.
        private func session(url: URL, callbackURLScheme: String?,
                             completionHandler: @escaping (URL?, Error?) -> Void) -> FHAuthenticatingSession {
            if #available(iOS 12, *) {
                let session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme,
                                                         completionHandler: completionHandler)
                if #available(iOS 13.0, *) {
                    session.presentationContextProvider = self
                }
                return session
            } else {
                let session = SFAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme, completionHandler: completionHandler)
                return session
            }
        }
    }

    /// Implementation of `ASWebAuthenticationPresentationContextProviding`.
    @available(iOS 11.0, *)
    extension OAuthViewController: ASWebAuthenticationPresentationContextProviding {
        @available(iOS 12.0, *)
        public func presentationAnchor(for _: ASWebAuthenticationSession) -> ASPresentationAnchor {
            return view.window!
        }
    }

    /// Abstraction of `SFAuthenticationSession` and `ASWebAuthentication`.
    protocol FHAuthenticatingSession {
        /// Initializes `FHAuthenticatingSession`.
        ///
        /// - Parameters:
        ///     - url: Authentication url.
        ///     - callbackURLScheme: Url to be called at the end.
        ///     - completionHandler: Handler to be called at the end.
        init(url URL: URL,
             callbackURLScheme: String?,
             completionHandler: @escaping (URL?, Error?) -> Void)

        /// Starts the authentication.
        ///
        /// - Returns: Success state of authentication.
        func start() -> Bool
        /// Cancels authentication.
        func cancel()
    }

    /// Make `ASWebAuthenticationSession` conforming to`ASWebAuthenticationSession`.
    @available(iOS 12.0, *)
    extension ASWebAuthenticationSession: FHAuthenticatingSession {}

    /// Make `SFAuthenticationSession` conforming to`ASWebAuthenticationSession`.
    @available(iOS 11.0, *)
    extension SFAuthenticationSession: FHAuthenticatingSession {}
#endif
