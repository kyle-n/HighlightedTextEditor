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
    
//    func testMarkdownPresetHighlighting() {
//        assertSnapshot(matching: AnyView(MarkdownEditorA()), as: .image)
//        assertSnapshot(matching: AnyView(MarkdownEditorB()), as: device)
//        assertSnapshot(matching: AnyView(MarkdownEditorC()), as: device)
//    }

    func testURLPresetHighlighting() {
        let urlEditor = URLEditor()
        let contentRect = NSRect(x: 0, y: 0, width: 480, height: 480)

        // Create the window and set the content view.
        let window = NSWindow(
            contentRect: contentRect,
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: urlEditor)
        window.makeKeyAndOrderFront(nil)

        let newWindow = NSWindow(
            contentRect: contentRect,
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)

        newWindow.contentView = NSHostingView(rootView: urlEditor)

        let myNSBitMapRep = newWindow.contentView!.bitmapImageRepForCachingDisplay(in: contentRect)!

        newWindow.contentView!.cacheDisplay(in: contentRect, to: myNSBitMapRep)

        let myNSImage = NSImage(size: myNSBitMapRep.size)
        myNSImage.addRepresentation(myNSBitMapRep)
        
        assertSnapshot(matching: myNSImage, as: .image)
    }

//    func testCustomFontTraits() {
//        assertSnapshot(matching: AnyView(FontTraitEditor()), as: device)
//    }
//
//    func testCustomNSAttributedStringKeyValues() {
//        assertSnapshot(matching: AnyView(NSAttributedStringKeyEditor()), as: device)
//    }
}
