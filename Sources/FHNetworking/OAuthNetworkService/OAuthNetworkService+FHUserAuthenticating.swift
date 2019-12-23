//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

import Foundation

extension OAuthNetworkService: FHUserAuthenticating {
    /// Returns the authenticated user if possible.
    /// - throws:`FHNetworkError.noUser` if `user` is not set
    public func getAuthenticatedUser() throws -> String {
        guard let user = user else {
            throw FHNetworkError.noUser
        }
        return user
    }

    /// Sets the currently authenticated `user`.
    public func setAuthenticatedUser(with user: String?) {
        self.user = user
    }
}
