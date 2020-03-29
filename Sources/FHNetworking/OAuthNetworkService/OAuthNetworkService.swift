//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

import Foundation
/// NetworkService which allows Auhtentication via *OAuth*. This class only supports
/// OAuth Version 1.0.
///
/// - Author: Florian Herzog
/// - Version: 1.0
open class OAuthNetworkService: FHNetworkService {
    // MARK: Attributes

    public var session: URLSession = { URLSession(configuration: .default) }()

    /// The url to which all requests are build relatively
    public private(set) var baseUrl: String

    /// Application dependent *OAuth Consumer Token* for signing requests.
    public private(set) var consumerToken: String
    /// Application dependent *OAuth Consumer Token Secret* for generating *OAuth Signature*.
    public private(set) var consumerTokenSecret: String

    /// Permanent *OAuth Access Token* for signing requests.
    private var accessToken: String?
    /// Permanent *OAuth Access Token Secret* for generating *OAuth Signature*.
    private var accessTokenSecret: String?

    /// The path for getting temporary *Request Token*.
    private var requestTokenPath: String
    /// The path for authorizing temporary *Request Token*.
    private var authorizePath: String
    /// The path for getting permanent *Access Token*.
    private var accessTokenPath: String

    /// URL which is called after token authorization.
    private var callbackUrl: String?

    /// The currently logged in user.
    var user: String?

    // MARK: Initialization

    /// Initializes the *OAuthNetworkService*.
    ///
    /// - Parameters:
    ///     - baseUrl: The url to which all requests are build relatively
    ///     - consumerToken: Application dependent *OAuth Consumer Token* for signing requests.
    ///     - consumerTokenSecret: Application dependent *OAuth Consumer Token Secret* for generating *OAuth Signature*.
    ///     - requestTokenPath: The path for getting temporary *Request Token*.
    ///     - authorizePath: The path for authorizing temporary *Request Token*.
    ///     - accessTokenPath: The path for getting permanent *Access Token*.
    ///     - accessToken: Permanent *OAuth Access Token* for signing requests.
    ///     - accessTokenSecret: Permanent *OAuth Access Token Secret* for generating *OAuth Signature*.
    ///     - callbackUrl: URL which is called after token authorization.
    public init(baseUrl: String, consumerToken: String, consumerTokenSecret: String,
                requestTokenPath: String, authorizePath: String, accessTokenPath: String,
                accessToken: String? = nil, and accessTokenSecret: String? = nil,
                callbackUrl: String? = nil) {
        self.baseUrl = baseUrl

        // Token initialization
        self.consumerToken = consumerToken
        self.consumerTokenSecret = consumerTokenSecret
        self.accessToken = accessToken
        self.accessTokenSecret = accessTokenSecret

        // Path initialization
        self.requestTokenPath = requestTokenPath
        self.authorizePath = authorizePath
        self.accessTokenPath = accessTokenPath

        // Authorization
        self.callbackUrl = callbackUrl
    }

    /// Authorizes the current *OAuthNetworkService* with known *Access Token* and *Access Token Secret*
    public func authorize(with accessToken: String, and accessTokenSecret: String) {
        self.accessToken = accessToken
        self.accessTokenSecret = accessTokenSecret
    }

    // MARK: Authorization

    /// Builds the *Authorization Header* for signing requests.
    ///
    /// - Parameters:
    ///     - request: The *Network Request* which should be signed.
    public func authorizationHeader(for request: FHNetworkRequest) -> String? {
        if let request = request as? OAuthNetworkRequest {
            return OAuthAuthentication(fullPath: baseUrl + request.path, method: request.method,
                                       consumerToken: consumerToken, consumerTokenSecret: consumerTokenSecret,
                                       token: request.token, tokenSecret: request.tokenSecret,
                                       verifier: request.verifier)
                .header
        } else {
            return OAuthAuthentication(fullPath: baseUrl + request.path, method: request.method,
                                       consumerToken: consumerToken, consumerTokenSecret: consumerTokenSecret,
                                       token: accessToken, tokenSecret: accessTokenSecret, queryParameters: request.parameters)
                .header
        }
    }

    /// Builds the url for authorization of *OAuathRequestToken* with *OAuathRequestTokenSecret*.
    ///
    /// - Parameters:
    ///     - requestToken: The temporary *OAuth Request Token*.
    ///     - requestTokenSecret: The temporary *OAuth Request Token Secret*.
    /// - Returns:URL with *OAuth* auhtorization in query parameters.
    private func authorizeUrlFrom(requestToken: String, requestTokenSecret: String) -> URL? {
        let header = OAuthAuthentication(fullPath: baseUrl + authorizePath, method: .get,
                                         consumerToken: consumerToken, consumerTokenSecret: consumerTokenSecret,
                                         token: requestToken, tokenSecret: requestTokenSecret)

        guard let authorizeBaseUrl = self.urlFor(path: self.authorizePath),
            var components = URLComponents(url: authorizeBaseUrl, resolvingAgainstBaseURL: false) else {
            return nil
        }

        components.queryItems = header.parameters
        components.queryItems?.append(URLQueryItem(name: "oauth_callback", value: callbackUrl))

        return components.url
    }

    // MARK: OAuthWorkflow

    /// Authorizes the current `OAuthNetworkService` with a given `AuthoriationHandler`.
    ///
    /// - Parameters:
    ///     - authorizationHandler: Handler for user authorization.
    ///     - completion: Completion handler for authorizing the current user.
    public func authorize(with authorizationHandler: OAuthAuthoriationHandler,
                          completion: @escaping (Result<(accessToken: String, accessTokenSecret: String), OAuthNetworkError>) -> Void) {
        getRequestToken { result in
            switch result {
            case let .success(response):
                self.authorizeRequestToken(requestToken: response.requestToken,
                                           requestTokenSecret: response.requestTokenSecret,
                                           with: authorizationHandler) { result in
                    switch result {
                    case let .success(authorizationResponse):
                        self.getAccessTokenWith(requestToken: response.requestToken,
                                                requestTokenSecret: response.requestTokenSecret,
                                                oauthVerifier: authorizationResponse.oauthVerifier,
                                                completion: completion)
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }

            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    // MARK: Get Request Token

    /// Number of tries to get the *OAuthRequestToken*.
    private var requestRequestTokenTries = 0

    /// Requests the *Request Token*.
    ///
    /// - Parameters:
    ///     - completion: The handler for processing the request result.
    func getRequestToken(completion: @escaping (Result<(requestToken: String, requestTokenSecret: String), OAuthNetworkError>) -> Void) {
        let request = OAuthNetworkRequest.requestRequestToken(path: requestTokenPath)
        self.request(request) { (result: Result<Data?, FHNetworkError>) in
            switch result {
            case let .success(response):
                self.requestRequestTokenTries = 0
                guard let data = response, let query = String(bytes: data, encoding: .utf8),
                    let responseDic = query.decodeQueryEncoded(),
                    responseDic["oauth_callback_confirmed"] == "1",
                    let requestToken = responseDic["oauth_token"] as? String,
                    let requestTokenSecret = responseDic["oauth_token_secret"] as? String else {
                    completion(.failure(.getRequestTokenFailed(.noData)))
                    return
                }
                completion(.success((requestToken: requestToken,
                                     requestTokenSecret: requestTokenSecret)))
            case let .failure(error):
                guard self.requestRequestTokenTries < 5 else {
                    completion(.failure(.getRequestTokenFailed(error)))
                    self.requestRequestTokenTries = 0
                    return
                }
                print("\(self.requestRequestTokenTries) try for getting request token: \(error.localizedDescription)")
                self.getRequestToken(completion: completion)
            }
        }
        requestRequestTokenTries += 1
    }

    // MARK: Authorize Request Token

    /// Authorizes the `requestToken` with the given `OAuthAuthoriationHandler`.
    ///
    /// - Parameters:
    ///     - requestToken: The temporary *OAuth Request Token*.
    ///     - requestTokenSecret: The temporary *OAuth Request Token Secret*.
    ///     - authorizationHandler: Handler for user authorization.
    ///     - completion: The handler for processing the request result.
    private func authorizeRequestToken(requestToken: String, requestTokenSecret: String,
                                       with authorizationHandler: OAuthAuthoriationHandler,
                                       completion: @escaping (Result<(oauthToken: String, oauthVerifier: String), OAuthNetworkError>) -> Void) {
        guard let authorizeUrl = self.authorizeUrlFrom(requestToken: requestToken,
                                                       requestTokenSecret: requestTokenSecret) else {
            completion(.failure(.authorizationFailed(.requestCreationFailed)))
            return
        }

        authorizationHandler.authorize(url: authorizeUrl, callbackUrl: callbackUrl) { result in
            switch result {
            case let .success(response):
                guard response.oauthToken == requestToken else {
                    completion(.failure(.authorizationFailed(nil)))
                    return
                }
                completion(.success((oauthToken: response.oauthToken, oauthVerifier: response.oauthVerifier)))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    // MARK: Get Access Token

    /// Number of tries to get the *OAuthAccessToken*.
    private var requestAccessTokenTries = 0

    /// Requests the  permanent *Access Token*.
    ///
    /// - Parameters:
    ///     - requestToken: The temporary *OAuth Request Token*.
    ///     - requestTokenSecret: The temporary *OAuth Request Token Secret*.
    ///     - completion: The handler for processing the request result
    func getAccessTokenWith(requestToken: String, requestTokenSecret: String, oauthVerifier: String,
                            completion: @escaping (Result<(accessToken: String, accessTokenSecret: String), OAuthNetworkError>) -> Void) {
        let request = OAuthNetworkRequest.requestAccessToken(path: accessTokenPath, token: requestToken, tokenSecret: requestTokenSecret, verifier: oauthVerifier)
        self.request(request) { (result: Result<Data?, FHNetworkError>) in
            switch result {
            case let .success(response):
                self.requestAccessTokenTries = 0
                guard let data = response, let query = String(bytes: data, encoding: .utf8),
                    let responseDic = query.decodeQueryEncoded(),
                    let requestToken = responseDic["oauth_token"] as? String,
                    let requestTokenSecret = responseDic["oauth_token_secret"] as? String else {
                    completion(.failure(.getAccessTokenFailed(.noData)))
                    return
                }
                completion(.success((accessToken: requestToken,
                                     accessTokenSecret: requestTokenSecret)))
            case let .failure(error):
                guard self.requestAccessTokenTries < 5 else {
                    completion(.failure(.getRequestTokenFailed(error)))
                    self.requestAccessTokenTries = 0
                    return
                }
                print("\(self.requestAccessTokenTries) try for getting accesss token: \(error.localizedDescription)")
                self.getAccessTokenWith(requestToken: requestToken, requestTokenSecret: requestTokenSecret,
                                        oauthVerifier: oauthVerifier, completion: completion)
            }
        }
        requestAccessTokenTries += 1
    }
}
