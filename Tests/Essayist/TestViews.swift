//
//  TestViews.swift
//  Essayist
//
//  Created by Kyle Nazario on 11/25/20.
//

import SwiftUI
import HighlightedTextEditor

struct MarkdownEditorA: View {
    @State var text: String
    
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
    @State var text: String
    
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
    @State var text: String
    
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

struct FontModifiersEditor: View {
    @State private var text: String = "The text is _formatted_"
    
    var body: some View {
        HighlightedTextEditor(text: $text, highlightRules: [])
            .defaultColor(.red)
            .defaultFont(.systemFont(ofSize: 30))
            .insertionPointColor(.green)
            .multilineTextAlignment(.trailing)
    }
}

#if os(macOS)
struct DrawsBackgroundEditor: View {
    @State private var text: String = "The text is _formatted_"
    @State private var drawsBackground: Bool = false
    
    var body: some View {
        HStack {
            HighlightedTextEditor(text: $text, highlightRules: [])
                .drawsBackground(drawsBackground)
                .backgroundColor(.red)
            Button("Toggle drawsBackground") { drawsBackground.toggle() }
        }
    }
}
#else
struct DrawsBackgroundEditor: View {
    var body: some View {
        EmptyView()
    }
}
#endif

struct BackgroundChangesEditor: View {
    @State private var text: String = "The text is _formatted_"
    @State private var allowsDocumentBackgroundColorChange: Bool = false
    
    #if os(macOS)
    @State var backgroundColor: NSColor = .red
    private var editor: some View {
        HighlightedTextEditor(text: $text, highlightRules: [])
            .backgroundColor(backgroundColor)
            .allowsDocumentBackgroundColorChange(allowsDocumentBackgroundColorChange)
    }
    #else
    @State var backgroundColor: UIColor = .red
    private var editor: some View {
        HighlightedTextEditor(text: $text, highlightRules: [])
            .backgroundColor(backgroundColor)
    }
    #endif
    
    var body: some View {
        HStack {
            editor
            VStack {
                Button("Toggle backgroundColor") {
                    if backgroundColor == .red {
                        backgroundColor = .blue
                    } else {
                        backgroundColor = .red
                    }
                }
                Button("Toggle allowsDocumentBackgroundColorChange") { allowsDocumentBackgroundColorChange.toggle() }
            }
        }
    }
}

struct AutocapitalizationTypeEditor: View {
    @State private var text1: String = ""
    @State private var text2: String = ""
    @State private var text3: String = ""
    @State private var text4: String = ""
    
    var body: some View {
        #if os(macOS)
        return EmptyView()
        #else
        let bindings = [$text1, $text2, $text3, $text4]
        return ForEach(0..<autocapitalizationTypes.count, id: \.self) { i -> AnyView in
            let type = autocapitalizationTypes[i]
            let binding = bindings[i]
            
            return HighlightedTextEditor(text: binding, highlightRules: [])
                .autocapitalizationType(type)
                .border(Color.black)
                .eraseToAnyView()
        }
        #endif
    }
}
