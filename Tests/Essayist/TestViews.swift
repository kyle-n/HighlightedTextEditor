//
//  TestViews.swift
//  Essayist
//
//  Created by Kyle Nazario on 11/25/20.
//

import SwiftUI
import HighlightedTextEditor

struct MarkdownEditor: View {
    @State private var text: String
    
    init() {
        let fileURL = URL(string: "file:///Users/kylenazario/apps/HighlightedTextEditor/Tests/Essayist/iOS-EssayistUITests/MarkdownSample.md")!
        let markdown = try! String(contentsOf: fileURL, encoding: .utf8)
        _text = State<String>(initialValue: markdown)
    }
    
    var body: some View {
        HighlightedTextEditor(text: $text, highlightRules: .markdown)
    }
}

let markdownWrapper = UIHostingController(rootView: MarkdownEditor())
