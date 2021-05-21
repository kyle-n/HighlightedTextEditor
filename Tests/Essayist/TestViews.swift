//
//  TestViews.swift
//  Essayist
//
//  Created by Kyle Nazario on 11/25/20.
//

import HighlightedTextEditor
import SwiftUI

let markdownFileURL =
    URL(
        string: "https://raw.githubusercontent.com/kyle-n/HighlightedTextEditor/main/Tests/Essayist/iOS-EssayistUITests/MarkdownSample.md"
    )!
let markdown = try! String(contentsOf: markdownFileURL, encoding: .utf8)

struct MarkdownEditorA: View {
    @State var text: String

    init() {
        let end = markdown.index(of: "## Blockquotes")!
        let firstPart = String(markdown.prefix(upTo: end))
        _text = State<String>(initialValue: firstPart)
    }

    var body: some View {
        HighlightedTextEditor(text: $text, highlightRules: .markdown)
    }
}

struct MarkdownEditorB: View {
    @State var text: String

    init() {
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
    @State var text: String

    init() {
        let endOfSecondPart = markdown.index(of: "\n\n## Tables")!
        let thirdPart = String(markdown[endOfSecondPart..<markdown.endIndex])
        _text = State<String>(initialValue: thirdPart)
    }

    var body: some View {
        HighlightedTextEditor(text: $text, highlightRules: .markdown)
    }
}

struct URLEditor: View {
    @State var text: String = "No formatting\n\nhttps://www.google.com/"

    var body: some View {
        HighlightedTextEditor(text: $text, highlightRules: .url)
    }
}

let betweenUnderscores = try! NSRegularExpression(pattern: "_[^_]+_", options: [])
#if os(macOS)
let fontTraits: NSFontDescriptor.SymbolicTraits = [.bold, .italic, .tightLeading]
typealias NSUIColor = NSColor
typealias NSUIFont = NSFont
#else
let fontTraits: UIFontDescriptor.SymbolicTraits = [.traitBold, .traitItalic, .traitTightLeading]
typealias NSUIColor = UIColor
typealias NSUIFont = UIFont
#endif

struct FontTraitEditor: View {
    @State private var text: String = "The text is _formatted_"

    var body: some View {
        HighlightedTextEditor(text: $text, highlightRules: [
            HighlightRule(pattern: betweenUnderscores, formattingRules: [
                TextFormattingRule(fontTraits: fontTraits)
            ])
        ])
    }
}

struct NSAttributedStringKeyEditor: View {
    @State private var text: String = "The text is _formatted_"

    var body: some View {
        HighlightedTextEditor(text: $text, highlightRules: [
            HighlightRule(pattern: betweenUnderscores, formattingRules: [
                TextFormattingRule(key: .font, value: NSUIFont.systemFont(ofSize: 20)),
                TextFormattingRule(key: .backgroundColor, value: NSUIColor.blue),
                TextFormattingRule(key: .foregroundColor, value: NSUIColor.red),
                TextFormattingRule(key: .underlineStyle, value: NSUnderlineStyle.single.rawValue),
                TextFormattingRule(key: .underlineColor, value: NSUIColor.purple)
            ])
        ])
    }
}

struct OnSelectionChangeEditor: View {
    @State private var text: String = ""
    @State private var selectionChanges: Int = 0
    @State private var selectedRange: NSRange? = nil

    var body: some View {
        VStack {
            HighlightedTextEditor(text: $text, highlightRules: [])
                .onSelectionChange { (range: NSRange) in
                    selectionChanges += 1
                    selectedRange = range
                }
            HStack {
                Text(String(selectionChanges))
                Text(selectedRangeString)
            }
        }
    }

    private var selectedRangeString: String {
        guard let selectedRange = selectedRange else { return "" }
        return "\(selectedRange.location) \(selectedRange.length)"
    }
}
