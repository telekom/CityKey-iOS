//
//  SCTopAlignLabel.swift
//  SmartCity
//
//  Created by Michael on 20.11.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

/**
 *
 * UILabel sub class to align the text to the top border
 *
 */
class SCTopAlignLabel: UILabel {
    
    override func drawText(in rect:CGRect) {
        guard let labelText = text else {  return super.drawText(in: rect) }
        
        let attributedText = NSAttributedString(string: labelText, attributes: [NSAttributedString.Key.font: font as Any])
        var newRect = rect
        newRect.size.height = attributedText.boundingRect(with: rect.size, options: .usesLineFragmentOrigin, context: nil).size.height
        
        if numberOfLines != 0 {
            newRect.size.height = min(newRect.size.height, CGFloat(numberOfLines) * font.lineHeight)
        }
        
        self.adjustsFontSizeToFitWidth = false;
        self.lineBreakMode = NSLineBreakMode.byTruncatingTail
        super.drawText(in: newRect)
    }
    
}
