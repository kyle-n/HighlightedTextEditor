//
//  macOS_EssayistUITests.swift
//  macOS-EssayistUITests
//
//  Created by Kyle Nazario on 11/27/20.
//

import SnapshotTesting
import SwiftUI
import XCTest

class macOS_EssayistUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = true

        let app = XCUIApplication()
        app.launch()
        let fullScreenButton = app.windows.firstMatch.buttons[XCUIIdentifierFullScreenWindow]
        _ = fullScreenButton.waitForExistence(timeout: 1)
        if fullScreenButton.exists {
            fullScreenButton.click()
        }
    }

    private func selectEditor(_ editorType: EditorType) {
        let window = XCUIApplication().windows.firstMatch
        window.popUpButtons["Select Editor"].click()
        window.menuItems[editorType.rawValue.uppercaseFirst()].click()

        if editorType == .blank {
            let textView = window.textViews.firstMatch
            _ = textView.waitForExistence(timeout: 3)
            textView.click()
            textView.typeKey("a", modifierFlags: .command)
            textView.typeKey(.delete, modifierFlags: [])
        }
    }

    private var screenshot: NSImage {
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

        assertSnapshot(matching: screenshot, as: .image)
    }

    func testMarkdownPreset() {
        let app = XCUIApplication()
        app.activate()

        let markdownEditors: [EditorType] = [.markdownA, .markdownB, .markdownC]
        let window = app.windows.firstMatch
        markdownEditors.forEach { markdownEditor in
            selectEditor(markdownEditor)
            assertSnapshot(matching: window.screenshot().image, as: .image)
        }
    }

    func testCustomNSAttributedStringKeyValues() {
        let app = XCUIApplication()
        app.activate()

        selectEditor(.key)

        assertSnapshot(matching: screenshot, as: .image)
    }

    func testURLPresetLinkClicks() {
        let app = XCUIApplication()
        app.launch()

        selectEditor(.url)

        let window = XCUIApplication().windows.firstMatch
        window.textViews.links.firstMatch.click()

        let safari = XCUIApplication(bundleIdentifier: "com.apple.Safari")
        let safariLaunched = safari.wait(for: .runningForeground, timeout: 5)

        XCTAssertTrue(safariLaunched)
    }

    func testOnSelectionChange() {
        let app = XCUIApplication()
        app.activate()

        selectEditor(.onSelectionChange)

        let window = app.windows.firstMatch
        let textView = window.textViews.firstMatch

        textView.click()
        textView.typeText("Cat")
        textView.doubleClick()

        let selectedRangeDisplay = app.staticTexts["6"]
        let selectionChangesDisplay = app.staticTexts["0 3"]
        let selectedRangeExists = selectedRangeDisplay.waitForExistence(timeout: 2)
        let selectionChangesExists = selectionChangesDisplay.waitForExistence(timeout: 2)

        XCTAssertTrue(selectedRangeExists)
        XCTAssertTrue(selectionChangesExists)
    }

    func testIntrospect() {
        let app = XCUIApplication()
        app.activate()

        selectEditor(.introspect)

        let window = app.windows.firstMatch
        let textView = window.textViews.firstMatch

        textView.click()
        textView.typeText("1")
        let disabledContent = textView.value as! String
        XCTAssertEqual(disabledContent, "")

        window.buttons["Toggle Enabled"].click()
        textView.click()
        textView.typeText("2")
        let enabledContent = textView.value as! String
        XCTAssertEqual(enabledContent, "2")
    }
}
