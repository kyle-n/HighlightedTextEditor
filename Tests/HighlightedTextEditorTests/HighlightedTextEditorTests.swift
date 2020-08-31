import XCTest
@testable import HighlightedTextEditor

final class HighlightedTextEditorTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(HighlightedTextEditor().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
