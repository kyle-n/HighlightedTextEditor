# HighlightedTextEditor

A simple, powerful SwiftUI text editor for iOS and macOS with live syntax highlighting.

Highlight what's important as your users type. 

![HighlightedTextEditor demo](https://raw.githubusercontent.com/kyle-n/kyle-n.github.io/master/static/img/hte-demo.gif)

## Installation

Supports iOS 13.0+ and macOS 10.15+.

Swift Package Manager: 

```
https://github.com/kyle-n/HighlightedTextEditor
```

## Usage

HighlightedTextEditor applies styles to text matching regex patterns you provide. You can apply multiple styles to each regex pattern, as shown in the example below. 

```swift
import HighlightedTextEditor

// highlights text between underscores
let boldItalics = try! NSRegularExpression(pattern: "_[^_]+_", options: [])

struct ContentView: View {
    @State private var text: String = "here is _bold emphasis text_"
    
    private let rules: [HighlightRule] = [
        HighlightRule(pattern: boldItalics, formattingRules: [
            TextFormattingRule(fontTraits: [.traitItalic, .traitBold]),
            TextFormattingRule(key: .foregroundColor, value: UIColor.red)
        ])
        // optional modifiers
        .autocapitalizationType(.words)
        .keyboardType(.numberPad)
        .autocorrectionType(.no)
    ]
    
    var body: some View {
        VStack {
            Text("Text editing with highlights")
            HighlightedTextEditor(text: $text, highlightRules: rules)
        }
    }
}
```

Notice the NSRegularExpression is instantiated **once**. It should not be recreated every time the view is redrawn. This [helps performance](https://stackoverflow.com/questions/41705728/optimize-nsregularexpression-performance). 

## Presets

I've included a few useful presets for syntax highlighting. If you have ideas for other useful presets, please feel free to [open a pull request](https://github.com/kyle-n/HighlightedTextEditor/pulls) with your preset code.

Current presets include:

- `markdown`
- `url` 

Example of using a preset:

```swift
HighlightedTextEditor(text: $text, highlightRules: HighlightedTextEditor.markdown)
```

## API

### HighlightedTextEditor

| Parameter | Type | Optional | Description |
| --- | --- | --- | --- |
| `text` | Binding<String> | No | Text content of the field |
| `highlightRules` | [HighlightRule] | No | Patterns and formatting for those patterns |
| `onEditingChanged` | () -> Void | Yes | Called when the user begins editing |
| `onCommit` | () -> Void | Yes | Called when the user stops editing |
| `onTextChange` | (String) -> Void | Yes | Called whenever `text` changes |

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

## Featured apps

Are you using HighlightedTextEditor in your app? I would love to feature you here! Please [open a pull request](https://github.com/kyle-n/HighlightedTextEditor/pulls) that adds a new bullet to the list below with your app's name and a link to its TestFlight or App Store page.

- [MongoKitten](https://apps.apple.com/us/app/id1484086700)

## Credits

AppKit text editor code based on [MacEditorTextView](https://gist.github.com/unnamedd/6e8c3fbc806b8deb60fa65d6b9affab0) by [Thiago Holanda](https://twitter.com/tholanda).

Created by [Kyle Nazario](https://twitter.com/kbn_au).
