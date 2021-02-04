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
        if !app.exists && counter > 0 {
            tryLaunch(counter - 1)
        }
    }
    
    func selectEditor(_ editorType: EditorType) {
        let app = XCUIApplication()
        let selectEditorMenu = app.buttons["Select Editor"]
        let _ = selectEditorMenu.waitForExistence(timeout: 5)
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
        nextKeyboardButton.press(forDuration: 0.9);
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

    func testFontModifiers() {
        assertSnapshot(matching: FontModifiersEditor().eraseToAnyView(), as: device)
    }

    func testBackgroundColor() {
        let backgroundChangesEditor = BackgroundChangesEditor()
        assertSnapshot(matching: backgroundChangesEditor.eraseToAnyView(), as: device)

        backgroundChangesEditor.backgroundColor = .blue
        assertSnapshot(matching: backgroundChangesEditor.eraseToAnyView(), as: device)
    }

    func testAutocapitalizationModifier() {
        tryLaunch()
        let app = XCUIApplication()

        selectEditor(.autocapitalizationType)

        let keySets = autocapitalizationTypes.map { type -> String in
            switch type {
            case .allCharacters:
                return "CAPS"
            case .none:
                return "none"
            case .sentences:
                return "Sentence.Case."
            case .words:
                return "One Two"
            default:
                return ""
            }
        }

        (0..<autocapitalizationTypes.count).forEach { i in
            let editor = app.textViews.element(boundBy: i)
            let keySet = keySets[i]

            editor.tap()
            for char in keySet {
                if char == " " {
                    app.keys["space"].tap()
                } else if char == "." {
                    app.keys["space"].doubleTap()
                } else {
                    app.keys[String(char)].tap()
                }
            }
        }

        // If it gets here without crashing because it can't find a key, the test has passed
    }

    // Tests screenshots for grey bar above keyboard with autocorrect suggestions
    func testAutocorrectionTypeModifier() {
        tryLaunch()
        let app = XCUIApplication()

        selectEditor(.autocorrectionType)

        let textView = app.textViews.firstMatch
        textView.tap()
        
        let IKey = app.keys["I"]
        let mKey = app.keys["m"]
        let space = app.keys["space"]
        let delete = app.keys["delete"]
        
        let _ = IKey.waitForExistence(timeout: 2)
        IKey.tap()
        mKey.tap()
        space.tap()
        
        var textViewValue = textView.value as! String
        XCTAssertEqual(textViewValue, "I’m ")
        
        // -------------------------------------------- //
        
        (0..<textViewValue.count).forEach { _ in
            delete.tap()
        }
        
        app.buttons["Toggle Autocorrect"].tap()
        
        // -------------------------------------------- //
        
        textView.tap()
        let _ = IKey.waitForExistence(timeout: 2)
        IKey.tap()
        mKey.tap()
        space.tap()
        
        textViewValue = textView.value as! String
        XCTAssertEqual(textViewValue, "Im ")
    }

    func testKeyboardTypeModifier() {
        tryLaunch()
        let app = XCUIApplication()

        selectEditor(.keyboardType)

        app.textViews.firstMatch.tap()
        sleep(1)
        (0...9).forEach { num in
            XCTAssertTrue(app.keys[String(num)].exists)
        }
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
        app.textViews["hlte"].links["https://www.google.com/"].tap()
        
        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        let safariLaunched = safari.wait(for: .runningForeground, timeout: 5)
        
        XCTAssertTrue(safariLaunched)
    }
}
