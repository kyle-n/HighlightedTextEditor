//
//  UITextView.swift
//
//
//  Created by Kyle Nazario on 11/13/20.
//

#if os(iOS)
import Foundation
import UIKit

extension UITextView {
    var markedTextNSRange: NSRange? {
        guard let markedTextRange = markedTextRange else { return nil }
        let location = offset(from: beginningOfDocument, to: markedTextRange.start)
        let length = offset(from: markedTextRange.start, to: markedTextRange.end)
        return NSRange(location: location, length: length)
    }
}
#endif
