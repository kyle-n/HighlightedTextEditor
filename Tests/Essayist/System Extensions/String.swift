//
//  String.swift
//  Essayist
//
//  Created by Kyle Nazario on 11/25/20.
//

import Foundation

extension String {
    func uppercaseFirst() -> Self {
        guard self.count > 0 else { return self }
        var copy = self
        let firstChar = copy.removeFirst()
        let uppercasedFirstLetter = firstChar.uppercased()
        return uppercasedFirstLetter + (copy)
    }
}
