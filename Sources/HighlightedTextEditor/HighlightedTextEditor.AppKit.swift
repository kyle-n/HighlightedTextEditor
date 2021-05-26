#if os(macOS)
/**
 *  MacEditorTextView
 *  Copyright (c) Thiago Holanda 2020
 *  https://twitter.com/tholanda
 *
 *  Modified by Kyle Nazario 2020
 *
 *  MIT license
 */

import AppKit
import Combine
import SwiftUI

public struct HighlightedTextEditor: NSViewRepresentable, HighlightingTextEditor {
    public struct Internals {
        public let textView: SystemTextView
        public let scrollView: SystemScrollView?
    }

    @Binding var text: String {
        didSet {
            onTextChange?(text)
        }
    }

    let highlightRules: [HighlightRule]

    private(set) var onEditingChanged: OnEditingChangedCallback?
    private(set) var onCommit: OnCommitCallback?
    private(set) var onTextChange: OnTextChangeCallback?
    private(set) var onSelectionChange: OnSelectionChangeCallback?
    private(set) var introspect: IntrospectCallback?

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

    public func makeNSView(context: Context) -> ScrollableTextView {
        let textView = ScrollableTextView()
        textView.delegate = context.coordinator

        return textView
    }

    public func updateNSView(_ view: ScrollableTextView, context: Context) {
        context.coordinator.updatingNSView = true

        let highlightedText = HighlightedTextEditor.getHighlightedText(
            text: text,
            highlightRules: highlightRules
        )

        view.attributedText = highlightedText
        runIntrospect(view)
        view.selectedRanges = context.coordinator.selectedRanges
        context.coordinator.updatingNSView = false
    }

    private func runIntrospect(_ view: ScrollableTextView) {
        guard let introspect = introspect else { return }
        let internals = Internals(textView: view.textView, scrollView: view.scrollView)
        introspect(internals)
    }
}

public extension HighlightedTextEditor {
    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: HighlightedTextEditor
        var selectedRanges: [NSValue] = []
        var updatingNSView = false

        init(_ parent: HighlightedTextEditor) {
            self.parent = parent
        }

        public func textView(
            _ textView: NSTextView,
            shouldChangeTextIn affectedCharRange: NSRange,
            replacementString: String?
        ) -> Bool {
            return true
        }

        public func textDidBeginEditing(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }

            parent.text = textView.string
            parent.onEditingChanged?()
        }

        public func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            let content = String(textView.textStorage?.string ?? "")

            parent.text = content
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

            parent.text = textView.string
            parent.onCommit?()
        }
    }
}

public extension HighlightedTextEditor {
    final class ScrollableTextView: NSView {
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

            let textView = NSTextView(frame: .zero, textContainer: textContainer)
            textView.autoresizingMask = .width
            textView.backgroundColor = NSColor.textBackgroundColor
            textView.delegate = self.delegate
            textView.drawsBackground = true
            textView.isHorizontallyResizable = false
            textView.isVerticallyResizable = true
            textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            textView.minSize = NSSize(width: 0, height: contentSize.height)
            textView.textColor = NSColor.labelColor

            return textView
        }()

        // MARK: - Init

        init() {
            self.attributedText = NSMutableAttributedString()

            super.init(frame: .zero)
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - Life cycle

        override public func viewWillDraw() {
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
}

public extension HighlightedTextEditor {
    func introspect(callback: @escaping IntrospectCallback) -> Self {
        var editor = self
        editor.introspect = callback
        return editor
    }

    func onCommit(_ callback: @escaping OnCommitCallback) -> Self {
        var editor = self
        editor.onCommit = callback
        return editor
    }

    func onEditingChanged(_ callback: @escaping OnEditingChangedCallback) -> Self {
        var editor = self
        editor.onEditingChanged = callback
        return editor
    }

    func onTextChange(_ callback: @escaping OnTextChangeCallback) -> Self {
        var editor = self
        editor.onTextChange = callback
        return editor
    }

    func onSelectionChange(_ callback: @escaping OnSelectionChangeCallback) -> Self {
        var editor = self
        editor.onSelectionChange = callback
        return editor
    }

    func onSelectionChange(_ callback: @escaping (_ selectedRange: NSRange) -> Void) -> Self {
        var editor = self
        editor.onSelectionChange = { ranges in
            guard let range = ranges.first else { return }
            callback(range)
        }
        return editor
    }
}
#endif
