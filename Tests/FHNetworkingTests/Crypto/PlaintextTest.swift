//
//  FHNetworking
//  Copyright © 2019, Florian Herzog
//

@testable import FHNetworking
import XCTest

final class PlaintextTest: XCTestCase {
    private let algorithm = PlainTextHashAlgorithm()

    func testType() {
        XCTAssertEqual(algorithm.hashMethod.rawValue, "PLAINTEXT")
    }

    private let exampleHashes: [(string: String, hash: String)] = [
        (string: "da39a3ee5e6b4b0d3255bfef95601890afd80709",
         hash: "da39a3ee5e6b4b0d3255bfef95601890afd80709"),
        (string: "e3b0c44298fc1c149afbf4c8996fb92427ae41e4",
         hash: "e3b0c44298fc1c149afbf4c8996fb92427ae41e4"),
        (string: "cf83e1357eefb8bdf1542850d66d8007d620e405",
         hash: "cf83e1357eefb8bdf1542850d66d8007d620e405"),
        (string: "3f4a921d36ce9ce47d0d13c5d85f2b0ff8318d28",
         hash: "3f4a921d36ce9ce47d0d13c5d85f2b0ff8318d28"),
        (string: "f63b931bd47417a81a538327af927da3eike875s",
         hash: "f63b931bd47417a81a538327af927da3eike875s"),
    ]

    func testHashing() {
        for hash in exampleHashes {
            XCTAssertEqual(algorithm.hash(string: hash.string, with: ""),
                           hash.hash)
        }
    }

    static var allTests = [
        ("testType", testType),
        ("testHashing", testHashing),
    ]
}
