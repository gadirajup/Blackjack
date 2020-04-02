import XCTest
@testable import server

final class serverTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(server().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
