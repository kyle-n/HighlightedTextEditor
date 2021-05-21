//
//  NSRegularExpression.swift
//
//
//  Created by Kyle Nazario on 5/20/21.
//

import Foundation

private let wholeString = try! NSRegularExpression(pattern: "^.*$", options: .dotMatchesLineSeparators)

public extension NSRegularExpression {
    static var all: NSRegularExpression {
        wholeString
    }
}
