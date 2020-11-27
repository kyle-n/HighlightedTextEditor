//
//  iOS_EssayistUITests.swift
//  iOS-EssayistUITests
//
//  Created by Kyle Nazario on 11/25/20.
//

import XCTest
import SnapshotTesting
import SwiftUI

class iOS_EssayistUITests: XCTestCase {
    
    private let device = Snapshotting<AnyView, UIImage>.image(layout: .device(config: .iPadPro12_9), traits: .init(userInterfaceStyle: .dark))

    override func setUpWithError() throws {
        continueAfterFailure = true
    }
    
    func testMarkdownPresetHighlighting() {
        assertSnapshot(matching: AnyView(MarkdownEditorA()), as: device)
        assertSnapshot(matching: AnyView(MarkdownEditorB()), as: device)
        assertSnapshot(matching: AnyView(MarkdownEditorC()), as: device)
    }

    func testURLPresetHighlighting() {
        assertSnapshot(matching: AnyView(URLEditor()), as: device)
    }

    func testCustomFontTraits() {
        assertSnapshot(matching: AnyView(FontTraitEditor()), as: device)
    }

    func testCustomNSAttributedStringKeyValues() {
        assertSnapshot(matching: AnyView(NSAttributedStringKeyEditor()), as: device)
    }
    
    func testTypingInMiddle() {
        let app = XCUIApplication()
        app.launch()
        
        let hlteTextView = app.textViews["hlte"]
        hlteTextView.tap()
        
        app.keys["A"].tap()
        
        let returnButton = app.buttons["Return"]
        returnButton.tap()
        returnButton.tap()
        
        app.keys["B"].tap()
        returnButton.tap()
        returnButton.tap()
        
        app.keys["D"].tap()
        returnButton.tap()
        returnButton.tap()
        
        // Move selection to after "B"
        hlteTextView
            .coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
            .withOffset(CGVector(dx: 30, dy: 60))
            .tap()
        returnButton.tap()
        returnButton.tap()
        app.keys["C"].tap()
        app.keys["a"].tap()
        sleep(2)
        app.keys["r"].tap()
        sleep(4)
        app.keys["s"].tap()
        
        XCTAssertEqual(hlteTextView.value as! String, "A\n\nB\n\nCars\n\nD")
    }
}
