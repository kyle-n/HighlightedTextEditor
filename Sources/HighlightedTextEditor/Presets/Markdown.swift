import SwiftUI
import Foundation

fileprivate let inlineCodeRegex = try! NSRegularExpression(pattern: "`[^`]*`", options: [])
fileprivate let codeBlockRegex = try! NSRegularExpression(pattern: "(`){3}((?!\\1).)+\\1{3}", options: [.dotMatchesLineSeparators])
fileprivate let headingRegex = try! NSRegularExpression(pattern: "^#{1,6}\\s.*$", options: [.anchorsMatchLines])
fileprivate let linkOrImageRegex = try! NSRegularExpression(pattern: "!?\\[([^\\[\\]]*)\\]\\((.*?)\\)", options: [])
fileprivate let linkOrImageTagRegex = try! NSRegularExpression(pattern: "!?\\[([^\\[\\]]*)\\]\\[(.*?)\\]", options: [])
fileprivate let boldRegex = try! NSRegularExpression(pattern: "((\\*|_){2})((?!\\1).)+\\1", options: [])
fileprivate let underscoreEmphasisRegex = try! NSRegularExpression(pattern: "(?<!_)_[^_]+_(?!\\*)", options: [])
fileprivate let asteriskEmphasisRegex = try! NSRegularExpression(pattern: "(?<!\\*)(\\*)((?!\\1).)+\\1(?!\\*)", options: [])
fileprivate let boldEmphasisAsteriskRegex = try! NSRegularExpression(pattern: "(\\*){3}((?!\\1).)+\\1{3}", options: [])
fileprivate let blockquoteRegex = try! NSRegularExpression(pattern: "^>.*", options: [.anchorsMatchLines])
fileprivate let horizontalRuleRegex = try! NSRegularExpression(pattern: "\n\n(-{3}|\\*{3})\n", options: [])
fileprivate let unorderedListRegex = try! NSRegularExpression(pattern: "^(\\-|\\*)\\s", options: [.anchorsMatchLines])
fileprivate let orderedListRegex = try! NSRegularExpression(pattern: "^\\d*\\.\\s", options: [.anchorsMatchLines])
fileprivate let buttonRegex = try! NSRegularExpression(pattern: "<\\s*button[^>]*>(.*?)<\\s*/\\s*button>", options: [])
fileprivate let strikethroughRegex = try! NSRegularExpression(pattern: "(~)((?!\\1).)+\\1", options: [])
fileprivate let tagRegex = try! NSRegularExpression(pattern: "^\\[([^\\[\\]]*)\\]:", options: [.anchorsMatchLines])
fileprivate let footnoteRegex = try! NSRegularExpression(pattern: "\\[\\^(.*?)\\]", options: [])
// courtesy https://www.regular-expressions.info/examples.html
fileprivate let htmlRegex = try! NSRegularExpression(pattern: "<([A-Z][A-Z0-9]*)\\b[^>]*>(.*?)</\\1>", options: [.dotMatchesLineSeparators, .caseInsensitive])

#if os(macOS)
let codeFont = NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .thin)
let headingTraits: NSFontDescriptor.SymbolicTraits = [.bold, .expanded]
let boldTraits: NSFontDescriptor.SymbolicTraits = [.bold]
let emphasisTraits: NSFontDescriptor.SymbolicTraits = [.italic]
let boldEmphasisTraits: NSFontDescriptor.SymbolicTraits = [.bold, .italic]
let secondaryBackground = NSColor.windowBackgroundColor
let lighterColor = NSColor.lightGray
let textColor = NSColor.labelColor
#else
let codeFont = UIFont.monospacedSystemFont(ofSize: UIFont.systemFontSize, weight: .thin)
let headingTraits: UIFontDescriptor.SymbolicTraits = [.traitBold, .traitExpanded]
let boldTraits: UIFontDescriptor.SymbolicTraits = [.traitBold]
let emphasisTraits: UIFontDescriptor.SymbolicTraits = [.traitItalic]
let boldEmphasisTraits: UIFontDescriptor.SymbolicTraits = [.traitBold, .traitItalic]
let secondaryBackground = UIColor.secondarySystemBackground
let lighterColor = UIColor.lightGray
let textColor = UIColor.label
#endif

public extension Sequence where Iterator.Element == HighlightRule {
    static var markdown: [HighlightRule] {
        [
            HighlightRule(pattern: inlineCodeRegex, formattingRule: TextFormattingRule(key: .font, value: codeFont)),
            HighlightRule(pattern: codeBlockRegex, formattingRule: TextFormattingRule(key: .font, value: codeFont)),
            HighlightRule(pattern: headingRegex, formattingRules: [
                TextFormattingRule(fontTraits: headingTraits),
                TextFormattingRule(key: .kern, value: 0.5)
            ]),
            HighlightRule(pattern: linkOrImageRegex, formattingRule: TextFormattingRule(key: .underlineStyle, value: NSUnderlineStyle.single.rawValue)),
            HighlightRule(pattern: linkOrImageTagRegex, formattingRule: TextFormattingRule(key: .underlineStyle, value: NSUnderlineStyle.single.rawValue)),
            HighlightRule(pattern: boldRegex, formattingRule: TextFormattingRule(fontTraits: boldTraits)),
            HighlightRule(pattern: asteriskEmphasisRegex, formattingRule: TextFormattingRule(fontTraits: emphasisTraits)),
            HighlightRule(pattern: underscoreEmphasisRegex, formattingRule: TextFormattingRule(fontTraits: emphasisTraits)),
            HighlightRule(pattern: boldEmphasisAsteriskRegex, formattingRule: TextFormattingRule(fontTraits: boldEmphasisTraits)),
            HighlightRule(pattern: blockquoteRegex, formattingRule: TextFormattingRule(key: .backgroundColor, value: secondaryBackground)),
            HighlightRule(pattern: horizontalRuleRegex, formattingRule: TextFormattingRule(key: .foregroundColor, value: lighterColor)),
            HighlightRule(pattern: unorderedListRegex, formattingRule: TextFormattingRule(key: .foregroundColor, value: lighterColor)),
            HighlightRule(pattern: orderedListRegex, formattingRule: TextFormattingRule(key: .foregroundColor, value: lighterColor)),
            HighlightRule(pattern: buttonRegex, formattingRule: TextFormattingRule(key: .foregroundColor, value: lighterColor)),
            HighlightRule(pattern: strikethroughRegex, formattingRules: [
                TextFormattingRule(key: .strikethroughStyle, value: NSUnderlineStyle.single.rawValue),
                TextFormattingRule(key: .strikethroughColor, value: textColor)
            ]),
            HighlightRule(pattern: tagRegex, formattingRule: TextFormattingRule(key: .foregroundColor, value: lighterColor)),
            HighlightRule(pattern: footnoteRegex, formattingRule: TextFormattingRule(key: .foregroundColor, value: lighterColor)),
            HighlightRule(pattern: htmlRegex, formattingRules: [
                TextFormattingRule(key: .font, value: codeFont),
                TextFormattingRule(key: .foregroundColor, value: lighterColor)
            ])
        ]
    }
}
