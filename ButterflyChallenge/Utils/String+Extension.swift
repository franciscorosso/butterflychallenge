//
//  String+Extension.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import Foundation

extension String {
    func localized(comment: String = "") -> String {
        NSLocalizedString(self,
                          bundle: .main,
                          value: self,
                          comment: comment)
    }

    /// Replaces `%d` (number) occurrence with the one given
    func localized(with number: Int) -> String {
        localized().replacingOccurrences(of: "%d", with: String(number))
    }

    /// Replaces `%@` (1 string only) occurrence with the string given
    func localized(with text: String) -> String {
        localized().replacingOccurrences(of: "%@", with: text)
    }

    /// Replaces `%1$s`, `%2$s`... (multiple strings) occurrences with the ones given in the array
    func localized(with strings: [String]) -> String {
        var localizedString = self.localized()
        // Handle indexed placeholders like `%1$s`, `%2$s`, etc.
        for (index, value) in strings.enumerated() {
            let placeholder = "%\(index + 1)$s"
            localizedString = localizedString.replacingOccurrences(of: placeholder, with: value)
        }
        // Handle non-indexed placeholders `%@`
        for value in strings {
            if let range = localizedString.range(of: "%@") {
                localizedString.replaceSubrange(range, with: value)
            }
        }
        return localizedString
    }
}
