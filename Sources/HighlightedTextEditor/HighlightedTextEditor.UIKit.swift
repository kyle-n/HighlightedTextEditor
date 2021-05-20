#if os(iOS)
import SwiftUI
import UIKit

public struct HighlightedTextEditor: UIViewRepresentable, HighlightingTextEditor {

    @Binding var text: String {
        didSet {
            self.onTextChange?(text)
        }
    }
    let highlightRules: [HighlightRule]
    private let textView = UITextView()
    
    private(set) var onEditingChanged                   : (() -> Void)?                   = nil
    private(set) var onCommit                           : (() -> Void)?                   = nil
    private(set) var onTextChange                       : ((String) -> Void)?             = nil

    private(set) var onSelectionChange     : OnSelectionChangeCallback?   = nil
    
    public init(
        text: Binding<String>,
        highlightRules: [HighlightRule]
    ) {
        _text = text
        self.highlightRules = highlightRules
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIView(context: Context) -> UITextView {
        let textView = self.textView
        textView.delegate = context.coordinator
        textView.isEditable = true
        textView.isScrollEnabled = true
        updateTextViewModifiers(textView)

        return textView
    }

    public func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.isScrollEnabled = false
        context.coordinator.updatingUIView = true
        
        let highlightedText = HighlightedTextEditor.getHighlightedText(
            text: text,
            highlightRules: highlightRules
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
            parent.onEditingChanged?()
        }
        
        public func textViewDidEndEditing(_ textView: UITextView) {
            parent.onCommit?()
        }
    }
}

extension HighlightedTextEditor {
    
    public func introspect(callback: (UITextView) -> Void) -> Self {
        callback(self.textView)
        return self
    }
    
    public func onSelectionChange(_ callback: @escaping (NSRange) -> Void) -> Self {
        var new = self
        new.onSelectionChange = { ranges in
            guard let range = ranges.first else { return }
            callback(range)
        }
        return new
    }
    
    public func onCommit(_ callback: @escaping () -> Void = {}) -> Self {
        var new = self
        new.onCommit = callback
        return new
    }
    
    public func onEditingChanged(_ callback: @escaping () -> Void) -> Self {
        var new = self
        new.onEditingChanged = callback
        return new
    }
    
    public func onTextChange(_ callback: @escaping (String) -> Void) -> Self {
        var new = self
        new.onTextChange = callback
        return new
    }
}
#endif
