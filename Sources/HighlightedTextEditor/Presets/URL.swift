//
//  URL.swift
//  Regex courtesy of https://urlregex.com
//
//  Created by Kyle Nazario on 10/25/20.
//

import Foundation
import SwiftUI

private let urlRegexPattern =
    "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
private let _urlRegex = try! NSRegularExpression(pattern: urlRegexPattern, options: [])

public extension Sequence where Iterator.Element == HighlightRule {
    static var url: [HighlightRule] {
        [
            HighlightRule(pattern: _urlRegex, formattingRules: [
                TextFormattingRule(key: .underlineStyle, value: NSUnderlineStyle.single.rawValue),
                TextFormattingRule(key: .link) { urlString, _ in
                    URL(string: urlString) as Any
                }
            ])
        ]
    }
}

public extension HighlightRule {
    static var urlRegex: NSRegularExpression {
        _urlRegex
    }
}
