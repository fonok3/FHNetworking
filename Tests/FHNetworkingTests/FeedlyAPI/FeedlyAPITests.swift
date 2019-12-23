//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

@testable import FHNetworking
import Foundation
import XCTest

final class FeedlyAPITests: XCTestCase {
    func testSearch() {
        let expectation = self.expectation(description: "Request Token")

        let networkService: FHNetworkService = FeedlyNetworkService.shared
        let searchRequest = FeedlyNetworkRequest.search("heise")

        networkService.request(searchRequest) { (result: Result<FeedlyResultsResponse, FHNetworkError>) in
            switch result {
            case let .success(response):
                print(response)
                expectation.fulfill()
            case let .failure(error):
                print(error)
            }
        }
        wait(for: [expectation], timeout: 5)
    }

    static var allTests = [
        ("testSearch", testSearch),
    ]
}
