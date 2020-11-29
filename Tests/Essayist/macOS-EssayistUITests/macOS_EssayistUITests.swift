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
    
}
