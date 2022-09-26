import XCTest
@testable import Utility


final class UtilityTests: XCTestCase {
    func test_sha256_fileName() {
        XCTAssertEqual("https://www.google.com/".imageFileName, "d0e196a0c25d35dd0a84593cbae0f38333aa58529936444ea26453eab28dfc86.jpg")
    }
}
