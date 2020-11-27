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
}
