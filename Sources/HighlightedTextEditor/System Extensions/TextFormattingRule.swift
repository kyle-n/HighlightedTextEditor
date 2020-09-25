//
//  File.swift
//  
//
//  Created by Kyle Nazario on 9/8/20.
//

import SwiftUI

#if os(iOS) && BETA
extension TextFormattingRule {
    @available(iOS 14.0, *)
    public init(foregroundColor color: Color, fontTraits: SymbolicTraits = []) {
        self.init(key: .foregroundColor, value: UIColor(color), fontTraits: fontTraits)
    }
    
    @available(iOS 14.0, *)
    public init(highlightColor color: Color, fontTraits: SymbolicTraits = []) {
        self.init(key: .backgroundColor, value: UIColor(color), fontTraits: fontTraits)
    }
}
#endif

#if os(macOS) && BETA
extension TextFormattingRule {
    @available(macOS 11.0, *)
    public init(foregroundColor color: Color, fontTraits: SymbolicTraits = []) {
        self.init(key: .foregroundColor, value: NSColor(color), fontTraits: fontTraits)
    }
    
    @available(macOS 11.0, *)
    public init(highlightColor color: Color, fontTraits: SymbolicTraits = []) {
        self.init(key: .backgroundColor, value: NSColor(color), fontTraits: fontTraits)
    }
}
#endif

