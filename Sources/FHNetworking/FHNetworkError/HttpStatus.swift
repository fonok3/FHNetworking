//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

/// HTTP status abstraction
public enum HttpStatus {
    /// Initializes the status code distinctions
    ///
    /// - Parameters:
    ///     - statusCode: Response status code of request
    ///     - error: possible request error
    public init(with statusCode: Int?, error: Error? = nil) {
        guard let statusCode = statusCode else {
            self = .unknownError(error: error)
            return
        }

        if 200 ..< 300 ~= statusCode {
            self = .success
        } else if statusCode == 401 {
            self = .unauthorized
        } else if statusCode == 404 {
            self = .notFound
        } else if 400 ..< 500 ~= statusCode {
            self = .clientError(status: statusCode, error: error)
        } else if 500 ..< 600 ~= statusCode {
            self = .serverError(status: statusCode, error: error)
        } else {
            self = .other(status: statusCode, error: error)
        }
    }

    /// Successfull request
    case success
    /// Unauthorized request
    case unauthorized
    /// Endpoint not found
    case notFound
    /// Server Errors
    case serverError(status: Int, error: Error?)
    /// Client Errors
    case clientError(status: Int, error: Error?)
    /// Other statuses
    case other(status: Int, error: Error?)
    /// Unknown error without status code
    case unknownError(error: Error?)
}
