//
//  macOS_EssayistUITests.swift
//  macOS-EssayistUITests
//
//  Created by Kyle Nazario on 11/27/20.
//

import XCTest
import SnapshotTesting
import SwiftUI

class macOS_EssayistUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = true
        
        let app = XCUIApplication()
        app.launch()
        app.windows.firstMatch.buttons[XCUIIdentifierFullScreenWindow].click()
    }
    
    private func selectEditor(_ editorType: EditorType) {
        let window = XCUIApplication().windows.firstMatch
        window.popUpButtons["Select Editor"].click()
        window.menuItems[editorType.rawValue.uppercaseFirst()].click()
    }
    
    private func screenshot() -> NSImage {
        XCUIApplication().windows.firstMatch.screenshot().image
    }
    
    func testTypingInMiddle() {
        let app = XCUIApplication()
        app.activate()
        
        let editor = app.textViews.firstMatch
        editor.click()
        editor.typeText("1 3")
        
        editor.typeKey(.leftArrow, modifierFlags: [])
        editor.typeKey(.leftArrow, modifierFlags: [])
        editor.typeKey(.space, modifierFlags: [])
        editor.typeText("two")
        
        XCTAssertEqual(editor.value as! String, "1 two 3")
    }
    
    func testURLPreset() {
        let app = XCUIApplication()
        app.activate()
        
        selectEditor(.url)

        assertSnapshot(matching: screenshot(), as: .image)
    }
    
    func testMarkdownPreset() {
        let app = XCUIApplication()
        app.activate()
        
        let markdownEditors: [EditorType] = [.markdownA, .markdownB, .markdownC]
        markdownEditors.forEach { markdownEditor in
            selectEditor(markdownEditor)
            assertSnapshot(matching: screenshot(), as: .image)
        }
    }
    
}
