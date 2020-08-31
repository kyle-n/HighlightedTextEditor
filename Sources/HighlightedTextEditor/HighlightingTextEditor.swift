//
//  File.swift
//  
//
//  Created by Kyle Nazario on 8/31/20.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

public struct HighlightRule {
    let pattern: NSRegularExpression
    let attributeKey: NSAttributedString.Key
    let attributeValue: Any
    
    public init(pattern: NSRegularExpression, attributeKey: NSAttributedString.Key, attributeValue: Any) {
        self.pattern = pattern
        self.attributeKey = attributeKey
        self.attributeValue = attributeValue
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
                highlightedString.addAttribute(rule.attributeKey, value: rule.attributeValue, range: match.range)
            }
        }
        
        return highlightedString
    }
}
