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
    
    var body: some View {
        VStack {
            editorView
            Picker("Select Editor", selection: $currentEditor) {
                ForEach(EditorType.allCases, id: \.self) { editorType in
                    Text(editorType.rawValue.uppercaseFirst())
                        .tag(editorType)
                        .accessibility(identifier: editorType.rawValue)
                }
            }
            .accessibility(identifier: "Select Editor")
        }
        .onChange(of: currentEditor) { _ in
            text = ""
        }
    }
    
    private var editorView: some View {
        switch currentEditor {
        case .blank:
            return HighlightedTextEditor(text: $text, highlightRules: [])
                .accessibility(identifier: "hlte")
                .eraseToAnyView()
        case .markdownA:
            return MarkdownEditorA()
                .accessibility(identifier: "hlte")
                .eraseToAnyView()
        case .markdownB:
            return MarkdownEditorB()
                .accessibility(identifier: "hlte")
                .eraseToAnyView()
        case .markdownC:
            return MarkdownEditorC()
                .accessibility(identifier: "hlte")
                .eraseToAnyView()
        case .url:
            return URLEditor()
                .accessibility(identifier: "hlte")
                .eraseToAnyView()
        }
    }
}
