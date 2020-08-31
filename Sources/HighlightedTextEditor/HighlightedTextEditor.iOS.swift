#if os(iOS)
import SwiftUI
import UIKit

struct HighlightedTextEditor: UIViewRepresentable, HighlightingTextEditor {

    @Binding var text: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isEditable = true
        textView.isScrollEnabled = true

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.isScrollEnabled = false
        
        let highlightedText = NSMutableAttributedString(string: "")

        print("self text", self.text)
        uiView.attributedText = highlightedText
        uiView.isScrollEnabled = true
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: HighlightedTextEditor

        init(_ markdownEditorView: HighlightedTextEditor) {
            self.parent = markdownEditorView
        }
        
        func textViewDidChange(_ textView: UITextView) {
            print("textView content:", textView.text!)
            self.parent.text = textView.text
//            textView.selectedRange = transformData.1
            print("post update parent text binding", self.parent.text)
        }
        
    }
}
#endif
