# HighlightedTextEditor

A simple, powerful SwiftUI text editor for iOS and macOS with live syntax highlighting.

Highlight what's important as your users type. 

![HighlightedTextEditor demo](https://raw.githubusercontent.com/kyle-n/kyle-n.github.io/master/static/img/hte-demo.gif)

## Installation

Supports iOS 13.0+ and macOS 10.15+.

### Swift Package Manager

File -> Swift Packages -> Add Package Dependency and use the URL `https://github.com/kyle-n/HighlightedTextEditor`.

### CocoaPods

Add `pod 'HighlightedTextEditor'` to your `Podfile` and run `pod install`. 

## Usage

HighlightedTextEditor applies styles to text matching regex patterns you provide. You can apply multiple styles to each regex pattern, as shown in the example below. 

```swift
import HighlightedTextEditor

// matches text between underscores
let betweenUnderscores = try! NSRegularExpression(pattern: "_[^_]+_", options: [])

struct ContentView: View {
    
    @State private var text: String = ""
    
    private let rules: [HighlightRule] = [
        HighlightRule(pattern: betweenUnderscores, formattingRules: [
            TextFormattingRule(fontTraits: [.traitItalic, .traitBold]),
            TextFormattingRule(key: .foregroundColor, value: UIColor.red),
            TextFormattingRule(key: .underlineStyle) { content, range in
                if content.count > 10 { return NSUnderlineStyle.double.rawValue }
                else { return NSUnderlineStyle.single.rawValue }
            }
        ])
    ]
    
    var body: some View {
        VStack {
            HighlightedTextEditor(text: $text, highlightRules: rules)
                // optional modifiers
                .onCommit { print("commited") }
                .onEditingChanged { print("editing changed") }
                .onTextChange { print("latest text value", $0) }
                .onSelectionChange { print("NSRange of current selection", $0)}
                .introspect { editor in
                    // access underlying UITextView or NSTextView
                    editor.textView.backgroundColor = .green
                }
        }
    }
}
```

Notice the NSRegularExpression is instantiated **once**. It should not be recreated every time the view is redrawn. This [helps performance](https://stackoverflow.com/questions/41705728/optimize-nsregularexpression-performance). 

## Presets

I've included a few useful presets for syntax highlighting as static vars on `[HighlightRule]`. If you have ideas for other useful presets, please feel free to [open a pull request](https://github.com/kyle-n/HighlightedTextEditor/pulls) with your preset code.

Current presets include:

- `markdown`
- `url` 

Example of using a preset:

```swift
HighlightedTextEditor(text: $text, highlightRules: .markdown)
```

### Regex Presets

I've also added a preset variable, `NSRegularExpression.all`, for easily selecting a whole string.

Example of using it:

```swift
HighlightedTextEditor(text: $text, highlightRules: [
    HighlightRule(pattern: .all, formattingRule: TextFormattingRule(key: .underlineStyle, value: NSUnderlineStyle.single.rawValue))
])
```

## API

### HighlightedTextEditor

| Parameter | Type | Description |
| --- | --- | --- |
| `text` | Binding&lt;String\> | Text content of the field |
| `highlightRules` | [HighlightRule] | Patterns and formatting for those patterns |

#### Modifiers

- `.introspect(callback: (_ editor: HighlightedTextEditorInternals) -> Void)`: Allows you the developer to access the underlying UIKit or AppKit objects used by HighlightedTextEditor
- `.onCommit(_ callback: @escaping () -> Void)`: Called when the user stops editing
- `.onEditingChanged(_ callback: @escaping () -> Void)`: Called when the user begins editing
- `.onTextChange(_ callback: @escaping (_ editorContent: String) -> Void)`: Called whenever `text` changes
- `.onSelectionChange(_ callback: @escaping (_ selectedRange: NSRange) -> Void)`
- `.onSelectionChange(_ callback: @escaping (_ selectedRanges: [NSRange]) -> Void)` (AppKit only)

### HighlightedTextEditorInternals

Passed as a parameter to `.introspect()` callbacks. Useful for customizing editor behavior in some way not supported by the HLTE API.

| Property | Type | Description |
| --- | --- | --- |
| `textView` | UITextView or NSTextView | For customizing the UIKit/AppKit text editor |
| `scrollView` | NSScrollView? | For customizing the NSScrollView wrapper. Returns `nil` in UIKit |

### HighlightRule

| Parameter | Type | Description |
| --- | --- | --- |
| `pattern` | NSRegularExpression | The content you want to highlight. Should be instantiated **once** for performance. |
| `formattingRule` | TextFormattingRule | Style applying to all text matching the `pattern` |
| `formattingRules` | [TextFormattingRule] | Array of styles applying to all text matching the `pattern` |

### TextFormattingRule

TextFormattingRule offers three different initializers that each set one style. To set multiple styles, use multiple TextFormattingRules.

| Parameter | Type | Description |
| --- | --- | --- |
| `key` | [NSAttributedString.Key](2) | The style to set (e.x. `.foregroundColor`, `.underlineStyle`) |
| `value` | Any | The actual style applied to the `key` (e.x. for `key = .foregroundColor`, `value` is `UIColor.red` or `NSColor.red`) |

| Parameter | Type | Description |
| --- | --- | --- |
| `key` | [NSAttributedString.Key](2) | The style to set (e.x. `.foregroundColor`, `.underlineStyle`) |
| `calculateValue` | (String, Range<String.Index>) -> Any | A callback that calculates the value for `key`. First parameter is the text content matched by the regex, second is the match's range in the overall string. |

`value` uses an older, untyped API so you'll have to check the [documentation](2) for what type can be passed in for a given `key`.

| Parameter | Type | Description |
| --- | --- | --- |
| `fontTraits` | [UIFontDescriptor.SymbolicTraits](3) or [NSFontDescriptor.SymbolicTraits](4) | Text formatting attributes (e.x. `[.traitBold]` in UIKit and `.bold` in AppKit) |

[2]: https://developer.apple.com/documentation/foundation/nsattributedstring/key

[3]: https://developer.apple.com/documentation/uikit/uifontdescriptor/symbolictraits

[4]: https://developer.apple.com/documentation/appkit/nsfontdescriptor/symbolictraits

If you are targeting iOS 14 / macOS 11, you can use a convenience initializer taking advantage of new SwiftUI APIs for converting Colors to UIColors or NSColors. 

| Parameter | Type | Description |
| --- | --- | --- |
| `foregroundColor` | Color | Color of the text |
| `fontTraits` | [UIFontDescriptor.SymbolicTraits](3) or [NSFontDescriptor.SymbolicTraits](4) | Text formatting attributes (e.x. `[.traitBold]` in UIKit and `.bold` in AppKit) |

Apple, in its wisdom, has not enabled these features for the XCode 12 GM. If you are using the XCode beta and want to enable this initializer, go to project_name -> Targets -> specified platform -> Build Settings -> Swift Compiler - Custom Flags and add flag `-DBETA`.
&lt;
## Featured apps

Are you using HighlightedTextEditor in your app? I would love to feature you here! Please [open a pull request](https://github.com/kyle-n/HighlightedTextEditor/pulls) that adds a new bullet to the list below with your app's name and a link to its TestFlight or App Store page.

- [MongoKitten](https://apps.apple.com/us/app/id1484086700)

## Credits

AppKit text editor code based on [MacEditorTextView](https://gist.github.com/unnamedd/6e8c3fbc806b8deb60fa65d6b9affab0) by [Thiago Holanda](https://twitter.com/tholanda).

Created by [Kyle Nazario](https://twitter.com/kbn_au).
