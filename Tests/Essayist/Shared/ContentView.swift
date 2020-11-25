//
//  ContentView.swift
//  Shared
//
//  Created by Kyle Nazario on 11/25/20.
//

import SwiftUI
import HighlightedTextEditor

struct ContentView: View {
    @State private var currentEditor: EditorType = .markdown
    @State private var text: String = ""
    
    var body: some View {
        VStack {
            editorView
            Picker("Select Editor", selection: $currentEditor) {
                ForEach(EditorType.allCases, id: \.self) { editorType in
                    Text(editorType.rawValue.uppercaseFirst())
                        .tag(editorType)
                }
            }
        }
    }
    
    private var editorView: some View {
        Group {
            switch currentEditor {
            case .markdown:
                HighlightedTextEditor(text: $text, highlightRules: .markdown)
            }
        }
    }
    
    private enum EditorType: String, CaseIterable {
        case markdown
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
