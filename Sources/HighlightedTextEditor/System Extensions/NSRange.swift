//
//  NSRange.swift
//
//
//  Created by Kyle Nazario on 2/8/21.
//

import Foundation

extension NSRange {
    func equals(_ range: NSRange) -> Bool {
        location == range.location && length == range.length
    }
}
