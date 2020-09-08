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
    
    let key: NSAttributedString.Key? = nil
    let value: Any? = nil
    let fontTraits: Array<SymbolicTraits> = []
    
    // ------------------- convenience ------------------------
    
    public init(key: NSAttributedString.Key, value: Any) {
        self.init(key: key, value: value, fontTraits: [])
    }
    
    public init(fontTrait: SymbolicTraits) {
        self.init(key: nil, value: nil, fontTraits: [fontTrait])
    }
    
    // ------------------ most powerful initializer ------------------
    
    public init(key: NSAttributedString.Key?, value: Any?, fontTraits: Array<SymbolicTraits>) {
        self.key = key
        self.value = value
        self.fontTraits = fontTraits
    }
}

public struct HighlightRule {
    let pattern: NSRegularExpression
    
    let formattingRules: Array<TextFormattingRule>
    
    // ------------------- convenience ------------------------
    
    public init(pattern: NSRegularExpression, highlightColor color: Color) {
        #if os(macOS)
        let convertedColor = NSColor(cgColor: color.cgColor!)
        #else
        let convertedColor = UIColor(color)
        #endif
        let backgroundColor = TextFormattingRule(key: .backgroundColor, value: convertedColor as Any)
        self.init(pattern: pattern, formattingRules: [backgroundColor])
    }
    
    public init(pattern: NSRegularExpression, foregroundColor color: Color) {
        #if os(macOS)
        let convertedColor = NSColor(cgColor: color.cgColor!)
        #else
        let convertedColor = UIColor(color)
        #endif
        let textColor = TextFormattingRule(key: .foregroundColor, value: convertedColor as Any)
        self.init(pattern: pattern, formattingRules: [textColor])
    }
    
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
                rule.formattingRules.forEach {
                    guard let key = $0.key, let value = $0.value else { return }
                    highlightedString.addAttribute(key, value: value, range: match.range)
                }
            }
        }
        
        return highlightedString
    }
}
