//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

/// Abstraction for authenticating by user
public protocol FHUserAuthenticating {
    /// Returns the authenticated user
    ///
    /// - Returns: Currently authenticated user
    func getAuthenticatedUser() throws -> String

    /// Sets the currently authenticated user
    ///
    /// - Parameters:
    ///     - user: Currently authenticated user
    func setAuthenticatedUser(with user: String?)
}
