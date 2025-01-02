//
//  UITextInput+TextRange.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 13/12/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

extension UITextInput {
    func textRange(for range: NSRange) -> UITextRange? {
        var result: UITextRange?

        if
            let start = position(from: beginningOfDocument, offset: range.location),
            let end = position(from: start, offset: range.length)
        {
            result = textRange(from: start, to: end)

        }

        return result
    }
}
