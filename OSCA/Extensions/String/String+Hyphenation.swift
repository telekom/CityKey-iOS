//
//  String+Hyphenation.swift
//  OSCA
//
//  Created by Ayush on 20/10/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

extension String {
    
    func applyHyphenation() -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.hyphenationFactor = 1.0;
        let attributedString = NSMutableAttributedString(string: self, attributes: [.paragraphStyle: paragraphStyle])
        return attributedString
    }
}
