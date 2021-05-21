//
//  ContentView.swift
//  Shared
//
//  Created by Kyle Nazario on 11/25/20.
//

import HighlightedTextEditor
import SwiftUI

struct ContentView: View {
    @State private var text: String = ""
    @State private var currentEditor: EditorType = .blank

    var layout: some View {
        VStack {
            editorView
                .accessibility(identifier: "hlte")
            #if os(macOS)
            picker
            #else
            picker
                .pickerStyle(MenuPickerStyle())
            #endif
        }
    }

    var picker: some View {
        Picker("Select Editor", selection: $currentEditor) {
            ForEach(EditorType.allCases, id: \.self) { editorType in
                Text(editorType.rawValue.uppercaseFirst())
                    .tag(editorType)
                    .accessibility(identifier: editorType.rawValue)
            }
        }
        .accessibility(identifier: "Select Editor")
    }

    var body: some View {
        #if os(macOS)
        layout
        #else
        layout
            .statusBar(hidden: true)
        #endif
    }

    private var editorView: some View {
        switch currentEditor {
        case .blank:
            return HighlightedTextEditor(text: $text, highlightRules: [])
                .eraseToAnyView()
        case .markdownA:
            return MarkdownEditorA()
                .eraseToAnyView()
        case .markdownB:
            return MarkdownEditorB()
                .eraseToAnyView()
        case .markdownC:
            return MarkdownEditorC()
                .eraseToAnyView()
        case .url:
            return URLEditor()
                .eraseToAnyView()
        case .key:
            return NSAttributedStringKeyEditor()
                .eraseToAnyView()
        case .onSelectionChange:
            return OnSelectionChangeEditor()
                .eraseToAnyView()
        case .modifiers:
            return ModifiersEditor()
                .eraseToAnyView()
        }
    }
}
