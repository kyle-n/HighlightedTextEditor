//
//  iOS_EssayistUITests.swift
//  iOS-EssayistUITests
//
//  Created by Kyle Nazario on 11/25/20.
//

import SnapshotTesting
import SwiftUI
import XCTest

class iOS_EssayistUITests: XCTestCase {
    private let device = Snapshotting<AnyView, UIImage>
        .image(layout: .device(config: .iPadPro12_9), traits: .init(userInterfaceStyle: .dark))

    private var screenshot: UIImage {
        XCUIApplication().screenshot().image
    }

    override class func setUp() {
        // enable Chinese-language keyboard
        let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        settings.launch()

        settings.tables.firstMatch.staticTexts["General"].tap()
        settings.tables.firstMatch.staticTexts["Keyboard"].tap()
        settings.tables.firstMatch.staticTexts["Keyboards"].tap()
        settings.tables.firstMatch.staticTexts["Add New Keyboard..."].tap()
        settings.tables.firstMatch.staticTexts["Chinese, Simplified"].tap()
        settings.tables.firstMatch.staticTexts["Pinyin – 10 Key"].tap()
        settings.buttons["Done"].tap()

        XCUIDevice.shared.press(.home)
    }

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    func tryLaunch(_ counter: Int = 10) {
        sleep(3)
        XCUIApplication().terminate()
        sleep(3)

        let app = XCUIApplication()
        app.launch()
        sleep(3)
        if !app.exists, counter > 0 {
            tryLaunch(counter - 1)
        }
    }

    func selectEditor(_ editorType: EditorType) {
        let app = XCUIApplication()
        let selectEditorMenu = app.buttons["Select Editor"]
        _ = selectEditorMenu.waitForExistence(timeout: 5)
        selectEditorMenu.tap()
        app.buttons[editorType.rawValue.uppercaseFirst()].tap()
    }

    private enum SimulatorKeyboards: String {
        case englishUS = "English (US)"
        case pinyin10Key = "简体拼音"
    }

    private func selectKeyboard(_ keyboardType: SimulatorKeyboards) {
        let app = XCUIApplication()
        let nextKeyboardButton = app.buttons["Next keyboard"]

        if !nextKeyboardButton.exists {
            app.textViews.firstMatch.tap()
        }
        nextKeyboardButton.press(forDuration: 0.9)
        app.tables["InputSwitcherTable"].staticTexts[keyboardType.rawValue].tap()
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
        tryLaunch()
        let app = XCUIApplication()

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
        app.keys["r"].tap()
        app.keys["s"].tap()

        XCTAssertEqual(hlteTextView.value as! String, "A\n\nB\n\nCars\n\nD\n\n")
    }

    func testTwoStageInput() {
        tryLaunch()
        let app = XCUIApplication()

        selectEditor(.blank)

        let hlteTextView = app.textViews["hlte"]
        hlteTextView.tap()

        let moreKey = app.keys["more"]
        let space = app.keys["space"]
        let returnButton = app.buttons["Return"]

        moreKey.tap()
        app.keys["1"].tap()
        app.keys["."].tap()
        space.tap()
        app.keys["A"].tap()
        returnButton.tap()
        moreKey.tap()
        app.keys["2"].tap()
        app.keys["."].tap()
        space.tap()
        app.keys["B"].tap()
        returnButton.doubleTap()

        app.keys["T"].tap()
        app.keys["e"].tap()
        app.keys["s"].tap()
        app.keys["t"].tap()
        space.tap()

        selectKeyboard(.pinyin10Key)

        app.keys["拼音"].tap()
        app.keys["A B C "].tap()
        app.keys["D E F "].tap()
        app.keys["M N O "].tap()
        app.collectionViews.staticTexts["笨"].tap()

        let targetText = """
        1. A
        2. B

        Test 笨
        """

        XCTAssertEqual(hlteTextView.value as! String, targetText)

        selectKeyboard(.englishUS)
    }

    func testURLPresetLinkTaps() {
        let app = XCUIApplication()
        app.launch()

        selectEditor(.url)
        app.textViews["hlte"].links.firstMatch.tap()

        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        let safariLaunched = safari.wait(for: .runningForeground, timeout: 5)

        XCTAssertTrue(safariLaunched)
    }

    func testOnSelectionChange() {
        let app = XCUIApplication()
        tryLaunch()

        selectEditor(.onSelectionChange)
        let textView = app.textViews.firstMatch
        _ = textView.waitForExistence(timeout: 2)

        textView.tap()
        app.keys["C"].tap()
        app.keys["a"].tap()
        app.keys["t"].tap()
        textView.doubleTap()

        let selectedRangeDisplay = app.staticTexts["5"]
        let selectionChangesDisplay = app.staticTexts["0 3"]
        let selectedRangeExists = selectedRangeDisplay.waitForExistence(timeout: 2)
        let selectionChangesExists = selectionChangesDisplay.waitForExistence(timeout: 2)

        XCTAssertTrue(selectedRangeExists)
        XCTAssertTrue(selectionChangesExists)
    }

    func testModifiers() {
        let app = XCUIApplication()
        app.launch()

        selectEditor(.modifiers)
        let textView = app.textViews.firstMatch
        _ = textView.waitForExistence(timeout: 2)

        textView.tap()
        app.keys["A"].tap()

        app.textFields.firstMatch.tap()

        let indicators = [
            app.staticTexts["editorContent: A"],
            app.staticTexts["startedEditing: true"],
            app.staticTexts["endedEditing: true"]
        ]
        indicators.forEach { indicator in
            XCTAssertTrue(indicator.exists)
        }
    }

    func testIntrospect() {
        let app = XCUIApplication()
        app.launch()

        selectEditor(.introspect)
        let textView = app.textViews.firstMatch
        _ = textView.waitForExistence(timeout: 2)

        textView.tap()
        let aKey = app.keys["A"]
        XCTAssertFalse(aKey.waitForExistence(timeout: 2))

        app.buttons["Toggle Enabled"].tap()
        textView.tap()
        XCTAssertTrue(aKey.waitForExistence(timeout: 2))
    }

    func testTypingEmoji() {
        let app = XCUIApplication()
        app.launch()

        selectEditor(.blank)

        let textView = app.textViews.firstMatch
        _ = textView.waitForExistence(timeout: 2)

        UIPasteboard.general.string = "💩"
        sleep(2)

        textView.tap()
        textView.doubleTap()
        app.menuItems["Paste"].tap()

        let textViewContent = textView.value as! String
        XCTAssertEqual(textViewContent, "💩")
    }
}
