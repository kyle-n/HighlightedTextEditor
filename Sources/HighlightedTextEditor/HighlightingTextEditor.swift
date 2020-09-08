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
    let key: NSAttributedString.Key
    let value: Any
    
    public init(key: NSAttributedString.Key, value: Any) {
        self.key = key
        self.value = value
    }
}

public struct HighlightRule {
    let pattern: NSRegularExpression
    
    let attributeKeyValues: Array<TextFormattingRule>
    
    // ------------------- convenience ------------------------
    
    public init(pattern: NSRegularExpression, highlightColor color: Color) {
        #if os(macOS)
        let convertedColor = NSColor(cgColor: color.cgColor!)
        #else
        let convertedColor = UIColor(color)
        #endif
        let backgroundColor = TextFormattingRule(key: .backgroundColor, value: convertedColor as Any)
        self.init(pattern: pattern, attributedStringKeyValues: [backgroundColor])
    }
    
    public init(pattern: NSRegularExpression, foregroundColor color: Color) {
        #if os(macOS)
        let convertedColor = NSColor(cgColor: color.cgColor!)
        #else
        let convertedColor = UIColor(color)
        #endif
        let textColor = TextFormattingRule(key: .foregroundColor, value: convertedColor as Any)
        self.init(pattern: pattern, attributedStringKeyValues: [textColor])
    }
    
    public init(pattern: NSRegularExpression, attributedStringKeyValue: TextFormattingRule) {
        self.init(pattern: pattern, attributedStringKeyValues: [attributedStringKeyValue])
    }
    
    // ------------------ most powerful initializer ------------------
    
    public init(pattern: NSRegularExpression, attributedStringKeyValues: Array<TextFormattingRule>) {
        self.pattern = pattern
        self.attributeKeyValues = attributedStringKeyValues
    }
}

internal protocol HighlightingTextEditor {
    var text: String { get set }
    var highlightRules: [HighlightRule] { get }
}

extension HighlightingTextEditor {
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
                rule.attributeKeyValues.forEach {
                    highlightedString.addAttribute($0.key, value: $0.value, range: match.range)
                }
            }
        }
        
        return highlightedString
    }
}
