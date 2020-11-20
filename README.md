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
    @State private var text: String = "here is _bold, italicized, red text_"
    
    private let rules: [HighlightRule] = [
        HighlightRule(pattern: betweenUnderscores, formattingRules: [
            TextFormattingRule(fontTraits: [.traitItalic, .traitBold]),
            TextFormattingRule(key: .foregroundColor, value: UIColor.red)
        ])
    ]
    
    var body: some View {
        VStack {
            HighlightedTextEditor(text: $text, highlightRules: rules)
                // optional modifiers
                .autocapitalizationType(.words)
                .keyboardType(.numberPad)
                .autocorrectionType(.no)
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

## API

### HighlightedTextEditor

| Parameter | Type | Optional | Description |
| --- | --- | --- | --- |
| `text` | Binding&lt;String\> | No | Text content of the field |
| `highlightRules` | [HighlightRule] | No | Patterns and formatting for those patterns |
| `onEditingChanged` | () -> Void | Yes | Called when the user begins editing |
| `onCommit` | () -> Void | Yes | Called when the user stops editing |
| `onTextChange` | (String) -> Void | Yes | Called whenever `text` changes |

#### Modifiers (UIKit)

- `.autocapitalizationType(_ type: UITextAutocapitalizationType)`
- `.autocorrectionType(_ type: UITextAutocorrectionType)`
- `.backgroundColor(_ color: UIColor)`
- `.defaultColor(_ color: UIColor)`
- `.defaultFont(_ font: UIFont)`
- `.keyboardType(_ type: UIKeyboardType)`
- `.insertionPointColor(_ color: UIColor)`
- `.multilineTextAlignment(_ alignment: TextAlignment)`

#### Modifiers (AppKit)

- `.allowsDocumentBackgroundColorChange(_ allowsChange: Bool)`
- `.backgroundColor(_ color: NSColor)`
- `.defaultColor(_ color: NSColor)`
- `.defaultFont(_ font: NSFont)`
- `.drawsBackground(_ shouldDraw: Bool)`
- `.insertionPointColor(_ color: NSColor)`
- `.multilineTextAlignment(_ alignment: TextAlignment)`

### HighlightRule

| Parameter | Type | Description |
| --- | --- | --- |
| `pattern` | NSRegularExpression | The content you want to highlight. Should be instantiated **once** for performance. |
| `formattingRule` | TextFormattingRule | Style applying to all text matching the `pattern` |
| `formattingRules` | [TextFormattingRule] | Array of styles applying to all text matching the `pattern` |

### TextFormattingRule

TextFormattingRule uses two different initializers that each set one style.

| Parameter | Type | Description |
| --- | --- | --- |
| `key` | [NSAttributedString.Key](2) | The style to set (e.x. `.foregroundColor`, `.underlineStyle`) |
| `value` | Any | The actual style applied to the `key` (e.x. for `key = .foregroundColor`, `value` is `UIColor.red` or `NSColor.red`) |

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
