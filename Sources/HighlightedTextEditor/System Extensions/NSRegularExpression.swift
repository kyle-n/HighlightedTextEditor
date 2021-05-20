//
//  NSRegularExpression.swift
//  
//
//  Created by Kyle Nazario on 5/20/21.
//

import Foundation

fileprivate let wholeString = try! NSRegularExpression(pattern: "^.*$", options: .dotMatchesLineSeparators)

extension NSRegularExpression {
    public static var all: NSRegularExpression {
        wholeString
    }
}
