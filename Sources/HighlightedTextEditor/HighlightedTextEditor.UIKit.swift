#if os(iOS)
import SwiftUI
import UIKit

public struct HighlightedTextEditor: UIViewRepresentable, HighlightingTextEditor {

    @Binding var text: String {
        didSet {
            self.onTextChange(text)
        }
    }
    let highlightRules: [HighlightRule]
    let textView = UITextView()
    
    var onEditingChanged                   : () -> Void                   = {}
    var onCommit                           : () -> Void                   = {}
    var onTextChange                       : (String) -> Void             = { _ in }
    
    // autocapitalizationType, autocorrectionType and keyboardType will be private(set) in a future 2.0.0 breaking release
                 var autocapitalizationType: UITextAutocapitalizationType = .sentences
                 var autocorrectionType    : UITextAutocorrectionType     = .default
    private(set) var backgroundColor       : UIColor?                     = nil
    private(set) var color                 : UIColor?                     = nil
    private(set) var font                  : UIFont?                      = nil
    private(set) var insertionPointColor   : UIColor?                     = nil
                 var keyboardType          : UIKeyboardType               = .default
    private(set) var onSelectionChange     : OnSelectionChangeCallback?   = nil
    private(set) var textAlignment         : TextAlignment                = .leading
    
    public init(
        text: Binding<String>,
        highlightRules: [HighlightRule],
        onEditingChanged: @escaping () -> Void = {},
        onCommit: @escaping () -> Void = {},
        onTextChange: @escaping (String) -> Void = { _ in }
    ) {
        _text = text
        self.highlightRules = highlightRules
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
        self.onTextChange = onTextChange
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIView(context: Context) -> UITextView {
        let textView = self.textView
        textView.delegate = context.coordinator
        textView.isEditable = true
        textView.isScrollEnabled = true
        textView.font = font
        updateTextViewModifiers(textView)

        return textView
    }

    public func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.isScrollEnabled = false
        context.coordinator.updatingUIView = true
        
        let highlightedText = HighlightedTextEditor.getHighlightedText(
            text: text,
            highlightRules: highlightRules,
            font: font,
            color: color
        )

        if let range = uiView.markedTextNSRange {
            uiView.setAttributedMarkedText(highlightedText, selectedRange: range)
        } else {
            uiView.attributedText = highlightedText
        }
        updateTextViewModifiers(uiView)
        uiView.isScrollEnabled = true
        uiView.selectedTextRange = context.coordinator.selectedTextRange
        context.coordinator.updatingUIView = false
    }
    
    private func updateTextViewModifiers(_ textView: UITextView) {
        // Keyboard properties are changed only if user closes the on-screen keyboard and reopens it (system behavior)
        textView.keyboardType = keyboardType
        textView.autocapitalizationType = autocapitalizationType
        textView.autocorrectionType = autocorrectionType
        
        textView.backgroundColor = backgroundColor
        let layoutDirection = UIView.userInterfaceLayoutDirection(for: textView.semanticContentAttribute)
        textView.textAlignment = NSTextAlignment(textAlignment: textAlignment, userInterfaceLayoutDirection: layoutDirection)
        textView.tintColor = insertionPointColor ?? textView.tintColor
    
        // BUGFIX #19: https://stackoverflow.com/questions/60537039/change-prompt-color-for-uitextfield-on-mac-catalyst
        let textInputTraits = textView.value(forKey: "textInputTraits") as? NSObject
        textInputTraits?.setValue(textView.tintColor, forKey: "insertionPointColor")
    }

    public class Coordinator: NSObject, UITextViewDelegate {
        var parent: HighlightedTextEditor
        var selectedTextRange: UITextRange? = nil
        var updatingUIView = false

        init(_ markdownEditorView: HighlightedTextEditor) {
            self.parent = markdownEditorView
        }
        
        public func textViewDidChange(_ textView: UITextView) {

            // For Multistage Text Input
            guard textView.markedTextRange == nil else { return }
            
            self.parent.text = textView.text
            selectedTextRange = textView.selectedTextRange
        }
        
        public func textViewDidChangeSelection(_ textView: UITextView) {
            guard let onSelectionChange = parent.onSelectionChange,
                  !updatingUIView
            else { return }
            selectedTextRange = textView.selectedTextRange
            onSelectionChange([textView.selectedRange])
        }
        
        public func textViewDidBeginEditing(_ textView: UITextView) {
            parent.onEditingChanged()
        }
        
        public func textViewDidEndEditing(_ textView: UITextView) {
            parent.onCommit()
        }
    }
}

extension HighlightedTextEditor {
    
    public func introspect(callback: (UITextView) -> Void) {
        callback(self.textView)
    }
}
#endif
