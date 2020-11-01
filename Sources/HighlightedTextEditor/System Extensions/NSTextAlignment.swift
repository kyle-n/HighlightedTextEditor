//
//  File.swift
//  
//
//  Created by Kyle Nazario on 11/1/20.
//

import Foundation
import SwiftUI
#if os(macOS)
import AppKit
fileprivate typealias SystemView = NSView
#else
import UIKit
fileprivate typealias SystemView = UIView
#endif

extension NSTextAlignment {
    internal init(textAlignment: TextAlignment, userInterfaceLayoutDirection direction: NSUserInterfaceLayoutDirection) {
        switch textAlignment {
        case .center:
            self.init(rawValue: NSTextAlignment.center.rawValue)!
        case .leading:
            self.init(rawValue: NSTextAlignment.natural.rawValue)!
        case .trailing:
            if direction == .leftToRight {
                self.init(rawValue: NSTextAlignment.right.rawValue)!
            } else {
                self.init(rawValue: NSTextAlignment.left.rawValue)!
            }
        }
    }
}
