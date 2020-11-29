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
    }
    
    func testTypingInMiddle() {
        let app = XCUIApplication()
        app.launch()
        
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
        app.launch()
        let window = app.windows.firstMatch
        
        window.popUpButtons["Select Editor"].click()
        window.menuItems["Url"].click()

        let editor = app.textViews.firstMatch
        editor.click()
        editor.typeText("Regular line\n\nhttps://www.google.com - link")
        sleep(5)

        let screenshot = app.windows.firstMatch.screenshot()
        assertSnapshot(matching: screenshot.image, as: .image)
    }
    
}
