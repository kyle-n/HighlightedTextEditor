//
//  Models.swift
//  Essayist
//
//  Created by Kyle Nazario on 11/25/20.
//

import Foundation

enum EditorType: String, CaseIterable, Equatable {
    case blank
    case markdownA
    case markdownB
    case markdownC
    case url
    case key
    case onSelectionChange
    case modifiers
}

#if !os(macOS)
import UIKit

let autocapitalizationTypes: [UITextAutocapitalizationType] = [.allCharacters, .none, .sentences, .words]

#endif
