/**
 *  MacEditorTextView
 *  Copyright (c) Thiago Holanda 2020
 *  https://twitter.com/tholanda
 *
 *  Modified by Kyle Nazario 2020
 *
 *  MIT license
 */
#if os(macOS)
import SwiftUI
import AppKit
import Combine

public struct HighlightedTextEditor: NSViewRepresentable, HighlightingTextEditor {
    
    @Binding var text: String {
        didSet {
            self.onTextChange?(text)
        }
    }
    let highlightRules: [HighlightRule]
    public let customTextView: CustomTextView = CustomTextView()
    
    private(set) var onEditingChanged: (() -> Void)?       = nil
    private(set) var onCommit        : (() -> Void)?       = nil
    private(set) var onTextChange    : ((String) -> Void)? = nil
    
    private(set) var onSelectionChange: (([NSRange]) -> Void)? = nil
    
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
    
    public func makeNSView(context: Context) -> CustomTextView {
        let textView = self.customTextView
        textView.delegate = context.coordinator
        
        return textView
    }
    
    public func updateNSView(_ view: CustomTextView, context: Context) {
        context.coordinator.updatingNSView = true
        
        let highlightedText = HighlightedTextEditor.getHighlightedText(
            text: text,
            highlightRules: highlightRules
        )
        
        view.attributedText = highlightedText
        view.selectedRanges = context.coordinator.selectedRanges
        context.coordinator.updatingNSView = false
    }
}

// MARK: - Coordinator
extension HighlightedTextEditor {
    
    public class Coordinator: NSObject, NSTextViewDelegate {

        var parent: HighlightedTextEditor
        var selectedRanges: [NSValue] = []
        var updatingNSView = false
        
        init(_ parent: HighlightedTextEditor) {
            self.parent = parent
        }
        
        public func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
            return true
        }
        
        public func textDidBeginEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            self.parent.text = textView.string
            self.parent.onEditingChanged?()
        }
        
        public func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            let content: String = String(textView.textStorage?.string ?? "")
            
            self.parent.text = content
            selectedRanges = textView.selectedRanges
        }
        
        public func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView,
                  let onSelectionChange = parent.onSelectionChange,
                  !updatingNSView,
                  let ranges = textView.selectedRanges as? [NSRange]
            else { return }
            selectedRanges = textView.selectedRanges
            DispatchQueue.main.async {
                onSelectionChange(ranges)
            }
        }
        
        public func textDidEndEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            self.parent.text = textView.string
            self.parent.onCommit?()
        }
    }
}

// MARK: - CustomTextView
public final class CustomTextView: NSView {
    
    weak var delegate: NSTextViewDelegate?
    
    var attributedText: NSAttributedString {
        didSet {
            textView.textStorage?.setAttributedString(attributedText)
        }
    }
    
    var selectedRanges: [NSValue] = [] {
        didSet {
            guard selectedRanges.count > 0 else {
                return
            }
            
            textView.selectedRanges = selectedRanges
        }
    }
    
    public lazy var scrollView: NSScrollView = {
        let scrollView = NSScrollView()
        scrollView.drawsBackground = true
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalRuler = false
        scrollView.autoresizingMask = [.width, .height]
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    
    public lazy var textView: NSTextView = {
        let contentSize = scrollView.contentSize
        let textStorage = NSTextStorage()
        
        
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        
        let textContainer = NSTextContainer(containerSize: scrollView.frame.size)
        textContainer.widthTracksTextView = true
        textContainer.containerSize = NSSize(
            width: contentSize.width,
            height: CGFloat.greatestFiniteMagnitude
        )
        
        layoutManager.addTextContainer(textContainer)
        
        
        let textView                     = NSTextView(frame: .zero, textContainer: textContainer)
        textView.autoresizingMask        = .width
        textView.backgroundColor         = NSColor.textBackgroundColor
        textView.delegate                = self.delegate
        textView.drawsBackground         = true
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable   = true
        textView.maxSize                 = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.minSize                 = NSSize(width: 0, height: contentSize.height)
        textView.textColor               = NSColor.labelColor
        
        return textView
    }()
    
    // MARK: - Init
    init() {
        self.attributedText = NSMutableAttributedString()
        
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    
    public override func viewWillDraw() {
        super.viewWillDraw()
        
        setupScrollViewConstraints()
        setupTextView()
    }
    
    func setupScrollViewConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
    }
    
    func setupTextView() {
        scrollView.documentView = textView
    }
    
}

extension HighlightedTextEditor {
    
    public func introspect(callback: (_ editor: CustomTextView) -> Void) -> Self {
        // Workaround for handling lazy-loaded vars
        customTextView.textView.accessibilityRole()
        callback(self.customTextView)
        return self
    }
    
    public func onCommit(_ callback: @escaping () -> Void) -> Self {
        var editor = self
        editor.onCommit = callback
        return editor
    }
    
    public func onEditingChanged(_ callback: @escaping () -> Void) -> Self {
        var editor = self
        editor.onEditingChanged = callback
        return editor
    }
    
    public func onTextChange(_ callback: @escaping (String) -> Void) -> Self {
        var editor = self
        editor.onTextChange = callback
        return editor
    }

    public func onSelectionChange(_ callback: @escaping ([NSRange]) -> Void) -> Self {
        var editor = self
        editor.onSelectionChange = callback
        return editor
    }
    
    public func onSelectionChange(_ callback: @escaping (NSRange) -> Void) -> Self {
        var editor = self
        editor.onSelectionChange = { ranges in
            guard let range = ranges.first else { return }
            callback(range)
        }
        return editor
    }
}
#endif
