# HighlightedTextEditor

A simple, powerful SwiftUI text editor for iOS and macOS with live syntax highlighting. Don't leave your users typing unstyled text in your app - highlight what's important as they type. 

## Installation

Xcode -> File -> Swift Packages -> Add Package Dependency -> `https://github.com/kyle-n/HighlightedTextEditor`

## Usage

**HighlightedTextEditor** requires regex patterns to highlight and styles to apply to those patterns. You can apply multiple styles to each regex pattern, as shown in the example below. 

```swift

let boldItalics = try! NSRegularExpression(pattern: "_[^_]+_", options: [])

struct ContentView: View {
    @State private var text: String = "abc _em_"
    
    private let rules: [HighlightRule] = [
        HighlightRule(pattern: boldItalics, formattingRules: [
            TextFormattingRule(fontTraits: [.traitItalic, .traitBold]),
            TextFormattingRule(key: .foregroundColor, value: UIColor.red)
        ])
    ]
    
    var body: some View {
        VStack {
            Text("Text editing with highlights")
            HighlightedTextEditor(text: $text, highlightRules: rules)
        }
    }
}
```

Notice the NSRegularExpression is instantiated **once**, not somewhere where it will be recreated when the view is redrawn. This [helps performance](https://stackoverflow.com/questions/41705728/optimize-nsregularexpression-performance). 

## API

### HighlightRule

| Parameter | Type | Description |
| ----------------------- |
| `pattern` | NSRegularExpression | The content you want to highlight. Should be instantiated **once** for performance. |
| `formattingRule` | TextFormattingRule | Style applying to all text matching the `pattern` |
| `formattingRules` | [TextFormattingRule] | Array of styles applying to all text matching the `pattern` |

### TextFormattingRule

| Parameter | Type | Requires iOS 14 / macOS 11.0 | Description |
| ------------------------------------------------ |
| `key` | [NSAttributedString.Key](2) | No | The style to set (e.x. `.foregroundColor`, `.underlineStyle`), |
| `value` | Any | No | The actual style applied to the `key` (e.x. for `key = .foregroundColor`, `value` is `UIColor.red` or `NSColor.red`). This is an older API and `value`'s type changes by `key`. |
| `fontTraits` | [UIFontDescriptor.SymbolicTraits](3) or [NSFontDescriptor.SymbolicTraits](4) | No | Text formatting attributes (e.x. `[.traitBold]` in UIKit and `.bold` in AppKit) |

[2]: https://developer.apple.com/documentation/foundation/nsattributedstring/key

[3]: https://developer.apple.com/documentation/uikit/uifontdescriptor/symbolictraits

[4]: https://developer.apple.com/documentation/appkit/nsfontdescriptor/symbolictraits
