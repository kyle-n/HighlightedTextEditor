//
//  HighlightingTextEditor.swift
//
//
//  Created by Kyle Nazario on 8/31/20.
//

import SwiftUI

#if os(macOS)
import AppKit

public typealias SystemFontAlias = NSFont
public typealias SystemColorAlias = NSColor
public typealias SymbolicTraits = NSFontDescriptor.SymbolicTraits
public typealias SystemTextView = NSTextView
public typealias SystemScrollView = NSScrollView

let defaultEditorFont = NSFont.systemFont(ofSize: NSFont.systemFontSize)
let defaultEditorTextColor = NSColor.labelColor

#else
import UIKit

public typealias SystemFontAlias = UIFont
public typealias SystemColorAlias = UIColor
public typealias SymbolicTraits = UIFontDescriptor.SymbolicTraits
public typealias SystemTextView = UITextView
public typealias SystemScrollView = UIScrollView

let defaultEditorFont = UIFont.preferredFont(forTextStyle: .body)
let defaultEditorTextColor = UIColor.label

#endif

public struct TextFormattingRule {
    public typealias AttributedKeyCallback = (String, Range<String.Index>) -> Any

    let key: NSAttributedString.Key?
    let calculateValue: AttributedKeyCallback?
    let fontTraits: SymbolicTraits

    // ------------------- convenience ------------------------

    public init(key: NSAttributedString.Key, value: Any) {
        self.init(key: key, calculateValue: { _, _ in value }, fontTraits: [])
    }

    public init(key: NSAttributedString.Key, calculateValue: @escaping AttributedKeyCallback) {
        self.init(key: key, calculateValue: calculateValue, fontTraits: [])
    }

    public init(fontTraits: SymbolicTraits) {
        self.init(key: nil, fontTraits: fontTraits)
    }

    // ------------------ most powerful initializer ------------------

    init(
        key: NSAttributedString.Key? = nil,
        calculateValue: AttributedKeyCallback? = nil,
        fontTraits: SymbolicTraits = []
    ) {
        self.key = key
        self.calculateValue = calculateValue
        self.fontTraits = fontTraits
    }
}

public struct HighlightRule {
    let pattern: NSRegularExpression

    let formattingRules: [TextFormattingRule]

    // ------------------- convenience ------------------------

    public init(pattern: NSRegularExpression, formattingRule: TextFormattingRule) {
        self.init(pattern: pattern, formattingRules: [formattingRule])
    }

    // ------------------ most powerful initializer ------------------

    public init(pattern: NSRegularExpression, formattingRules: [TextFormattingRule]) {
        self.pattern = pattern
        self.formattingRules = formattingRules
    }
}

internal protocol HighlightingTextEditor {
    var text: String { get set }
    var highlightRules: [HighlightRule] { get }
}

public typealias OnSelectionChangeCallback = ([NSRange]) -> Void
public typealias IntrospectCallback = (_ editor: HighlightedTextEditor.Internals) -> Void
public typealias EmptyCallback = () -> Void
public typealias OnCommitCallback = EmptyCallback
public typealias OnEditingChangedCallback = EmptyCallback
public typealias OnTextChangeCallback = (_ editorContent: String) -> Void

extension HighlightingTextEditor {
    var placeholderFont: SystemColorAlias { SystemColorAlias() }

    static func getHighlightedText(text: String, highlightRules: [HighlightRule]) -> NSMutableAttributedString {
        let highlightedString = NSMutableAttributedString(string: text)
        let all = NSRange(location: 0, length: text.utf16.count)

        let editorFont = defaultEditorFont
        let editorTextColor = defaultEditorTextColor

        highlightedString.addAttribute(.font, value: editorFont, range: all)
        highlightedString.addAttribute(.foregroundColor, value: editorTextColor, range: all)

        highlightRules.forEach { rule in
            let matches = rule.pattern.matches(in: text, options: [], range: all)
            matches.forEach { match in
                rule.formattingRules.forEach { formattingRule in

                    var font = SystemFontAlias()
                    highlightedString.enumerateAttributes(in: match.range, options: []) { attributes, _, _ in
                        let fontAttribute = attributes.first { $0.key == .font }!
                        // swiftlint:disable:next force_cast
                        let previousFont = fontAttribute.value as! SystemFontAlias
                        font = previousFont.with(formattingRule.fontTraits)
                    }
                    highlightedString.addAttribute(.font, value: font, range: match.range)

                    let matchRange = Range<String.Index>(match.range, in: text)!
                    let matchContent = String(text[matchRange])
                    guard let key = formattingRule.key,
                          let calculateValue = formattingRule.calculateValue else { return }
                    highlightedString.addAttribute(
                        key,
                        value: calculateValue(matchContent, matchRange),
                        range: match.range
                    )
                }
            }
        }

        return highlightedString
    }
}
