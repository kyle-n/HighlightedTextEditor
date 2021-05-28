//
//  NSFont.swift
//
//
//  Created by Kyle Nazario on 9/8/20.
//  Based on UIFont extension by Maksymilian Wojakowski
//

#if os(macOS)
import AppKit
import Foundation

extension NSFont {
    var bold: NSFont {
        return with(.bold)
    }

    var italic: NSFont {
        return with(.italic)
    }

    var boldItalic: NSFont {
        return with([.bold, .italic])
    }

    func with(_ traits: NSFontDescriptor.SymbolicTraits...) -> NSFont {
        let traitSet = NSFontDescriptor.SymbolicTraits(traits).union(fontDescriptor.symbolicTraits)
        let descriptor: NSFontDescriptor = fontDescriptor.withSymbolicTraits(traitSet)
        return NSFont(descriptor: descriptor, size: 0) ?? self
    }

    func without(_ traits: NSFontDescriptor.SymbolicTraits...) -> NSFont {
        let traitSet = fontDescriptor.symbolicTraits.subtracting(NSFontDescriptor.SymbolicTraits(traits))
        let descriptor = fontDescriptor.withSymbolicTraits(traitSet)
        return NSFont(descriptor: descriptor, size: 0) ?? self
    }
}
#endif
