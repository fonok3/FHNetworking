//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

@testable import FHNetworking
import XCTest

final class SHA1Test: XCTestCase {
    private let algorithm = SHA1HashAlgorithm()

    func testType() {
        XCTAssertEqual(algorithm.hashMethod.rawValue, "HMAC-SHA1")
    }

    private let exampleHashes: [(string: String, key: String, hash: String)] = [
        (string: "e3b0c44298fc1c149afbf4c8996fb92427ae41e4",
         key: "3f4a921d36ce9ce47d0d13c5d85f2b0ff8318d28",
         hash: "LMx5siTtjwdF/E3ACvwnembU7/8="),
        (string: "cf83e1357eefb8bdf1542850d66d8007d620e405",
         key: "3f4a921d36ce9ce47d0d13c5d85f2b0ff8318d28",
         hash: "3QwtjnccYmYRshIYePLsXGXwINA="),
        (string: "3f4a921d36ce9ce47d0d13c5d85f2b0ff8318d28",
         key: "3f4a921d36ce9ce47d0d13c5d85f2b0ff8318d28",
         hash: "LMkWn6EBni22onqkp1aGb9RF3II="),
    ]

    func testHashing() {
        for hash in exampleHashes {
            XCTAssertEqual(algorithm.hash(string: hash.string, with: hash.key), hash.hash)
        }
    }

    static var allTests = [
        ("testType", testType),
        ("testHashing", testHashing),
    ]
}
