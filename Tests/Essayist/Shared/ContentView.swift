//
//  ContentView.swift
//  Shared
//
//  Created by Kyle Nazario on 11/25/20.
//

import SwiftUI
import HighlightedTextEditor

struct ContentView: View {
    @State private var text: String = ""
    @State private var currentEditor: EditorType = .blank
    
    var layout: some View {
        VStack {
            editorView
                .accessibility(identifier: "hlte")
            Picker("Select Editor", selection: $currentEditor) {
                ForEach(EditorType.allCases, id: \.self) { editorType in
                    Text(editorType.rawValue.uppercaseFirst())
                        .tag(editorType)
                        .accessibility(identifier: editorType.rawValue)
                }
            }
            .accessibility(identifier: "Select Editor")
        }
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
        case .font:
            return FontTraitEditor()
                .eraseToAnyView()
        case .key:
            return NSAttributedStringKeyEditor()
                .eraseToAnyView()
        case .fontModifiers:
            return FontModifiersEditor()
                .eraseToAnyView()
        case .drawsBackground:
            return DrawsBackgroundEditor()
                .eraseToAnyView()
        case .backgroundChanges:
            return BackgroundChangesEditor()
                .eraseToAnyView()
        case .autocapitalizationType:
            return AutocapitalizationTypeEditor()
                .eraseToAnyView()
        case .autocorrectionType:
            return AutocorrectionTypeEditor()
                .eraseToAnyView()
        case .keyboardType:
            return KeyboardTypeEditor()
                .eraseToAnyView()
        }
    }
}
