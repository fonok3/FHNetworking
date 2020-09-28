//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

import FHNetworking
import Foundation

final class FeedlyNetworkService: FHNetworkService {
    var session: URLSession = .shared

    static var shared: FeedlyNetworkService = FeedlyNetworkService()

    var baseUrl: String

    private init() {
        baseUrl = "http://cloud.feedly.com"
    }
}
