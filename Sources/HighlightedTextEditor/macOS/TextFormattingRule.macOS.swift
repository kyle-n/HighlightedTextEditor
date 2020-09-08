//
//  File.swift
//  
//
//  Created by Kyle Nazario on 9/8/20.
//

#if os(macOS)
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
