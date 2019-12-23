//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

import Foundation

struct FeedlyFeedResponse: Codable {
    var feedId: String
    var id: String
    var lastUpdated: Date

    var title: String
    var description: String

    var website: String
    var subscribers: Int

    var coverUrl: String?
    var iconUrl: String?
    var visualUrl: String?
}
