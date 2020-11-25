//
//  iOS_EssayistUITests.swift
//  iOS-EssayistUITests
//
//  Created by Kyle Nazario on 11/25/20.
//

import XCTest

class iOS_EssayistUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    private func selectEditor(_ editorType: EditorType) {
        let app = XCUIApplication()
        app.pickerWheels.firstMatch.adjust(toPickerWheelValue: editorType.rawValue.uppercaseFirst())
        sleep(1)
    }
    
    private func type(_ text: String) {
        let textView = XCUIApplication().textViews.firstMatch
        textView.tap()
        sleep(1)
        UIPasteboard.general.string = text
        textView.doubleTap()
        XCUIApplication().menuItems.element(boundBy: 0).tap()
        sleep(1)
    }

    func testMarkdownHighlight() throws {
        let app = XCUIApplication()
        app.launch()
        
        selectEditor(.markdown)

        type("Testing **one** _two_ `three`")
    }
}
