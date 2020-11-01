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
    
    var onEditingChanged                   : () -> Void                   = {}
    var onCommit                           : () -> Void                   = {}
    var onTextChange                       : (String) -> Void             = { _ in }
    private(set) var keyboardType          : UIKeyboardType               = .default
    private(set) var autocapitalizationType: UITextAutocapitalizationType = .sentences
    private(set) var autocorrectionType    : UITextAutocorrectionType     = .default
    
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
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isEditable = true
        textView.isScrollEnabled = true
        textView.keyboardType = keyboardType
        textView.autocapitalizationType = autocapitalizationType
        textView.autocorrectionType = autocorrectionType

        return textView
    }

    public func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.isScrollEnabled = false
        
        let highlightedText = HighlightedTextEditor.getHighlightedText(text: text, highlightRules: highlightRules)

        uiView.attributedText = highlightedText
        uiView.isScrollEnabled = true
        uiView.selectedTextRange = context.coordinator.selectedTextRange
    }

    public class Coordinator: NSObject, UITextViewDelegate {
        var parent: HighlightedTextEditor
        var selectedTextRange: UITextRange? = nil

        init(_ markdownEditorView: HighlightedTextEditor) {
            self.parent = markdownEditorView
        }
        
        public func textViewDidChange(_ textView: UITextView) {
            self.parent.text = textView.text
            selectedTextRange = textView.selectedTextRange
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
    
    public func keyboardType(_ type: UIKeyboardType) -> Self {
        var new = self
        new.keyboardType = type
        return new
    }
    
    public func autocapitalizationType(_ type: UITextAutocapitalizationType) -> Self {
        var new = self
        new.autocapitalizationType = type
        return new
    }
    
    public func autocorrectionType(_ type: UITextAutocorrectionType) -> Self {
        var new = self
        new.autocorrectionType = type
        return new
    }
}
#endif
