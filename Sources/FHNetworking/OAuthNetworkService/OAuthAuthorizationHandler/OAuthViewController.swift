//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

#if os(iOS)
import UIKit
import Foundation
import AuthenticationServices
import SafariServices

@available(iOS 11.0, *)
open class OAuthViewController: UIViewController, OAuthAuthoriationHandler {

    open var networkService: OAuthNetworkService?
    private var session: FHAuthenticatingSession?

    public func authorize() {
        guard let networkService = networkService else {
            fatalError("No network service set.")
        }

        networkService.authorize(with: self) { (result) in
            DispatchQueue.main.async {
                self.session?.cancel()
                self.session = nil
                self.authorizationCompleted(with: result)
            }
        }
    }

    open func authorizationCompleted(with result:
        Result<(accessToken: String, accessTokenSecret: String), OAuthNetworkError>) {}

    public func authorize(url: URL, callbackUrl: String?, completion: @escaping (Result<(oauthToken: String, oauthVerifier: String), OAuthNetworkError>) -> Void) {
        DispatchQueue.main.async {
            self.session = self.session(url: url, callbackURLScheme: callbackUrl) { (url, error) in

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

    private func session(url: URL, callbackURLScheme: String?, completionHandler: @escaping (URL?, Error?) -> Void) -> FHAuthenticatingSession {
        #if targetEnvironment(macCatalyst)
            let session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme, completionHandler: completionHandler)
            session.presentationContextProvider = self
            return session
        #else
            if #available(iOS 12, *) {
                let session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme, completionHandler: completionHandler)
                if #available(iOS 13.0, *) {
                    session.presentationContextProvider = self
                }
                return session
            } else {
                let session = SFAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme, completionHandler: completionHandler)
                return session
            }
        #endif
    }
}

@available(iOS 11.0, *)
extension OAuthViewController: ASWebAuthenticationPresentationContextProviding {
    @available(iOS 12.0, *)
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return view.window!
    }
}

protocol FHAuthenticatingSession {
    init(url URL: URL,
         callbackURLScheme: String?,
         completionHandler: @escaping (URL?, Error?) -> Void)

    func start() -> Bool
    func cancel()
}

@available(iOS 12.0, *)
extension ASWebAuthenticationSession: FHAuthenticatingSession {}

#if !targetEnvironment(macCatalyst)
@available(iOS 11.0, *)
extension SFAuthenticationSession: FHAuthenticatingSession {}
#endif
#endif
