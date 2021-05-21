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
typealias LayoutDirection = NSUserInterfaceLayoutDirection
#else
import UIKit
typealias LayoutDirection = UIUserInterfaceLayoutDirection
#endif

extension NSTextAlignment {
    init(textAlignment: TextAlignment, userInterfaceLayoutDirection direction: LayoutDirection) {
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
