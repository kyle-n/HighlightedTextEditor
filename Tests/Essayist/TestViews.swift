//
//  TestViews.swift
//  Essayist
//
//  Created by Kyle Nazario on 11/25/20.
//

import SwiftUI
import HighlightedTextEditor

struct MarkdownEditorA: View {
    @State private var text: String
    
    init() {
        let fileURL = URL(string: "file:///Users/kylenazario/apps/HighlightedTextEditor/Tests/Essayist/iOS-EssayistUITests/MarkdownSample.md")!
        let markdown = try! String(contentsOf: fileURL, encoding: .utf8)
        let end = markdown.index(of: "## Blockquotes")!
        let firstPart = String(markdown.prefix(upTo: end))
        _text = State<String>(initialValue: firstPart)
    }
    
    var body: some View {
        HighlightedTextEditor(text: $text, highlightRules: .markdown)
    }
}

struct MarkdownEditorB: View {
    @State private var text: String
    
    init() {
        let fileURL = URL(string: "file:///Users/kylenazario/apps/HighlightedTextEditor/Tests/Essayist/iOS-EssayistUITests/MarkdownSample.md")!
        let markdown = try! String(contentsOf: fileURL, encoding: .utf8)
        let endOfFirstPart = markdown.index(of: "## Blockquotes")!
        let endOfSecondPart = markdown.index(of: "\n\n## Tables")!
        let secondPart = String(markdown[endOfFirstPart..<endOfSecondPart])
        _text = State<String>(initialValue: secondPart)
    }
    
    var body: some View {
        HighlightedTextEditor(text: $text, highlightRules: .markdown)
    }
}

struct MarkdownEditorC: View {
    @State private var text: String
    
    init() {
        let fileURL = URL(string: "file:///Users/kylenazario/apps/HighlightedTextEditor/Tests/Essayist/iOS-EssayistUITests/MarkdownSample.md")!
        let markdown = try! String(contentsOf: fileURL, encoding: .utf8)
        let endOfSecondPart = markdown.index(of: "\n\n## Tables")!
        let thirdPart = String(markdown[endOfSecondPart..<markdown.endIndex])
        _text = State<String>(initialValue: thirdPart)
    }
    
    var body: some View {
        HighlightedTextEditor(text: $text, highlightRules: .markdown)
    }
}

struct URLEditor: View {
    @State private var text: String = "No formatting\n\nhttps://www.google.com/"
    
    var body: some View {
        HighlightedTextEditor(text: $text, highlightRules: .url)
    }
}
