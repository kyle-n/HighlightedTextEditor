//
//  File.swift
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

let defaultEditorFont = NSFont.systemFont(ofSize: NSFont.systemFontSize)
let defaultEditorTextColor = NSColor.labelColor

#else
import UIKit

public typealias SystemFontAlias = UIFont
public typealias SystemColorAlias = UIColor
public typealias SymbolicTraits = UIFontDescriptor.SymbolicTraits

let defaultEditorFont = UIFont.preferredFont(forTextStyle: .body)
let defaultEditorTextColor = UIColor.label

#endif

public struct TextFormattingRule {
    
    let key: NSAttributedString.Key?
    let value: Any?
    let fontTraits: SymbolicTraits
    
    // ------------------- convenience ------------------------
    
    public init(key: NSAttributedString.Key, value: Any) {
        self.init(key: key, value: value, fontTraits: [])
    }
    
    public init(fontTraits: SymbolicTraits) {
        self.init(key: nil, value: nil, fontTraits: fontTraits)
    }
    
    // ------------------ most powerful initializer ------------------
    
    init(key: NSAttributedString.Key? = nil, value: Any? = nil, fontTraits: SymbolicTraits = []) {
        self.key = key
        self.value = value
        self.fontTraits = fontTraits
    }
}

public struct HighlightRule {
    let pattern: NSRegularExpression
    
    let formattingRules: Array<TextFormattingRule>
    
    // ------------------- convenience ------------------------
    
    public init(pattern: NSRegularExpression, formattingRule: TextFormattingRule) {
        self.init(pattern: pattern, formattingRules: [formattingRule])
    }
    
    // ------------------ most powerful initializer ------------------
    
    public init(pattern: NSRegularExpression, formattingRules: Array<TextFormattingRule>) {
        self.pattern = pattern
        self.formattingRules = formattingRules
    }
}

internal protocol HighlightingTextEditor {
    var text: String { get set }
    var highlightRules: [HighlightRule] { get }
}



extension HighlightingTextEditor {
    
    var placeholderFont: SystemColorAlias {
        get { SystemColorAlias() }
    }
    
    static func getHighlightedText(text: String, highlightRules: [HighlightRule], font: SystemFontAlias?, color: SystemColorAlias?) -> NSMutableAttributedString {
        let highlightedString = NSMutableAttributedString(string: text)
        let all = NSRange(location: 0, length: text.count)
        
        let editorFont = font ?? defaultEditorFont
        let editorTextColor = color ?? defaultEditorTextColor
        
        highlightedString.addAttribute(.font, value: editorFont, range: all)
        highlightedString.addAttribute(.foregroundColor, value: editorTextColor, range: all)
        
        highlightRules.forEach { rule in
            let matches = rule.pattern.matches(in: text, options: [], range: all)
            matches.forEach { match in
                rule.formattingRules.forEach { formattingRule in
                    
                    var font = SystemFontAlias()
                    highlightedString.enumerateAttributes(in: match.range, options: []) { attributes, range, stop in
                        let fontAttribute = attributes.first { $0.key == .font }!
                        let previousFont = fontAttribute.value as! SystemFontAlias
                        font = previousFont.with(formattingRule.fontTraits)
                    }
                    highlightedString.addAttribute(.font, value: font, range: match.range)
                    
                    guard let key = formattingRule.key, let value = formattingRule.value else { return }
                    highlightedString.addAttribute(key, value: value, range: match.range)
                }
            }
        }
        
        return highlightedString
    }
}
