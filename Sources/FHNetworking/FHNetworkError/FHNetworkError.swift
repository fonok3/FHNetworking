//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

import Foundation

/// Errors which occurs while executing network requests
public enum FHNetworkError: Error {
    /// HTTP Error
    case httpError(HttpStatus, String?)

    /// Error while decoding JSON response.
    case decodingError(DecodingError?)

    /// Request could not be created.
    case requestCreationFailed

    /// Response does not include any data.
    case noData

    /// No user has been set to the service.
    case noUser

    public var localizedDescription: String {
        switch self {
            case let .httpError(status, message):
                return "HTTP Error: \(status) \n\(message ?? "")"
            case let .decodingError(error):
                return "Decoding Error: \(error?.localizedDescription ?? "Unknown")"
            case .requestCreationFailed:
                return "Request could not be created"
            case .noData:
                return "Response does not include any data."
            case .noUser:
                return "No user has been set to the service."
        }
    }
}
