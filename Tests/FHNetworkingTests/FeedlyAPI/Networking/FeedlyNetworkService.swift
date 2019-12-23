//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

import FHNetworking

final class FeedlyNetworkService: FHNetworkService {
    static var shared: FeedlyNetworkService = FeedlyNetworkService()

    var baseUrl: String

    private init() {
        baseUrl = "http://cloud.feedly.com"
    }
}
