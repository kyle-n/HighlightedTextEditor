//
//  URL.swift
//  Regex courtesy of https://urlregex.com
//
//  Created by Kyle Nazario on 10/25/20.
//

import Foundation
import SwiftUI

fileprivate let urlRegexPattern = "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
fileprivate let urlRegex = try! NSRegularExpression(pattern: urlRegexPattern, options: [])

public extension HighlightedTextEditor {
    static let url: [HighlightRule] = [
        HighlightRule(pattern: urlRegex, formattingRule: TextFormattingRule(key: .underlineStyle, value: NSUnderlineStyle.single.rawValue))
    ]
}
