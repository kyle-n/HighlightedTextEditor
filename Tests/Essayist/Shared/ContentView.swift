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
    @State private var currentEditor: EditorType = .markdown
    
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
        Group {
            switch currentEditor {
            case .markdown:
                HighlightedTextEditor(text: $text, highlightRules: .markdown)
            case .url:
                HighlightedTextEditor(text: $text, highlightRules: .url)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
