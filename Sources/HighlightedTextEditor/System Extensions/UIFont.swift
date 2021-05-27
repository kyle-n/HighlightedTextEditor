//
//  UIFont.swift
//
//
//  Created by Kyle Nazario on 9/8/20.
//  Based on NSFont extension by Maksymilian Wojakowski
//

#if os(iOS)
import Foundation
import UIKit

extension UIFont {
    var bold: UIFont {
        return with(.traitBold)
    }

    var italic: UIFont {
        return with(.traitItalic)
    }

    var boldItalic: UIFont {
        return with([.traitBold, .traitItalic])
    }

    func with(_ traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        let traitSet = UIFontDescriptor.SymbolicTraits(traits).union(fontDescriptor.symbolicTraits)
        guard let descriptor = fontDescriptor.withSymbolicTraits(traitSet) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: 0)
    }

    func without(_ traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        let traitSet = fontDescriptor.symbolicTraits.subtracting(UIFontDescriptor.SymbolicTraits(traits))
        guard let descriptor = fontDescriptor.withSymbolicTraits(traitSet) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: 0)
    }
}
#endif
