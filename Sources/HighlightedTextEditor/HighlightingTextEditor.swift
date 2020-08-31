//
//  File.swift
//  
//
//  Created by Kyle Nazario on 8/31/20.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif

internal protocol HighlightingTextEditor {
    var text: String { get set }
    let highlightPatterns: [NSRegularExpression] { get }
}
