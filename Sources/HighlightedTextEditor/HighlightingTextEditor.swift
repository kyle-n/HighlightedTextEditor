//
//  File.swift
//  
//
//  Created by Kyle Nazario on 8/31/20.
//

import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

public struct TextFormattingRule {
    #if os(macOS)
    public typealias SymbolicTraits = NSFontDescriptor.SymbolicTraits
    #else
    public typealias SymbolicTraits = UIFontDescriptor.SymbolicTraits
    #endif
    
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
    
    public init(key: NSAttributedString.Key? = nil, value: Any? = nil, fontTraits: SymbolicTraits = []) {
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
    
    #if os(macOS)
    var placeholderFont: NSFont {
        get { NSFont() }
    }
    #else
    var placeholderFont: UIFont {
        get { UIFont() }
    }
    #endif
    
    static func getHighlightedText(text: String, highlightRules: [HighlightRule]) -> NSMutableAttributedString {
        let highlightedString = NSMutableAttributedString(string: text)
        let all = NSRange(location: 0, length: text.count)
        
        #if os(macOS)
        let systemFont = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        let systemTextColor = NSColor.labelColor
        #else
        let systemFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        let systemTextColor = UIColor.label
        #endif
        
        highlightedString.addAttribute(.font, value: systemFont, range: all)
        highlightedString.addAttribute(.foregroundColor, value: systemTextColor, range: all)
        
        highlightRules.forEach { rule in
            let matches = rule.pattern.matches(in: text, options: [], range: all)
            matches.forEach { match in
                rule.formattingRules.forEach { formattingRule in
                    
                    #if os(macOS)
                    var font = NSFont()
                    #else
                    var font = UIFont()
                    #endif
                    highlightedString.enumerateAttributes(in: match.range, options: []) { attributes, range, stop in
                        let fontAttribute = attributes.first { $0.key == .font }!
                        #if os(macOS)
                        let previousFont = fontAttribute.value as! NSFont
                        #else
                        let previousFont = fontAttribute.value as! UIFont
                        #endif
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
