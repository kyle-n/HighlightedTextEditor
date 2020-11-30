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

    override func setUpWithError() throws {
        continueAfterFailure = true
    }
    
    func selectEditor(_ editorType: EditorType) {
        let app = XCUIApplication()
        app.buttons["Select Editor"].tap()
        app.buttons[editorType.rawValue.uppercaseFirst()].tap()
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
        let app = XCUIApplication()
        app.launch()

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
        let app = XCUIApplication()
        app.launch()

        selectEditor(.autocorrectionType)

        app.textViews.firstMatch.tap()
        sleep(1)
        assertSnapshot(matching: screenshot, as: .image)
        app.buttons["Toggle Autocorrect"].tap()
        app.textViews.firstMatch.tap()
        sleep(1)
        assertSnapshot(matching: screenshot, as: .image)
    }
    
    func testKeyboardTypeModifier() {
        let app = XCUIApplication()
        app.launch()
        
        selectEditor(.keyboardType)
        
        app.textViews.firstMatch.tap()
        sleep(1)
        (0...9).forEach { num in
            XCTAssertTrue(app.keys[String(num)].exists)
        }
    }
}
