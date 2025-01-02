//
//  NSMutableAttributedString+Link+Underscore.swift
//  SmartCity
//
//  Created by Michael on 03.12.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {
    
    
    public func setAsStrikeThrough(textToFind:String) -> Bool {
        
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(NSAttributedString.Key.strikethroughStyle , value: NSUnderlineStyle.single.rawValue, range: foundRange)
            return true
        }
        return false
    }

    public func setAsUnderscore(textToFind:String) -> Bool {
        
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(NSAttributedString.Key.underlineStyle , value: NSUnderlineStyle.single.rawValue, range: foundRange)
            return true
        }
        return false
    }
    
    public func setTextColor(textToFind:String, color:UIColor) -> Bool {
        
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(NSAttributedString.Key.foregroundColor, value: color , range: foundRange)
            return true
        }
        return false
    }

    public func setAsLightFont(textToFind:String, fontSize: CGFloat) -> Bool {
        
        let lightFont = UIFont.systemFont(ofSize: fontSize) // and set new font here .

        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(NSAttributedString.Key.font , value: lightFont, range: foundRange)

            return true
        }
        return false
    }
    
    public func setAsBoldFont(textToFind:String, fontSize: CGFloat) -> Bool {
        
        let boldFont = UIFont.boldSystemFont(ofSize: fontSize) // and set new font here .
        
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(NSAttributedString.Key.font , value: boldFont, range: foundRange)
            
            return true
        }
        return false
    }

    func removeFont() {
        beginEditing()
        self.enumerateAttribute(.font, in: NSRange(location: 0, length: self.length)) { (value, range, stop) in
            removeAttribute(.font, range: range)
        }
        endEditing()
    }

    func replaceFont(with font: UIFont, color: UIColor) {
        beginEditing()
        self.enumerateAttribute(.font, in: NSRange(location: 0, length: self.length)) { (value, range, stop) in
            if let f = value as? UIFont {
                let ufd = f.fontDescriptor.withFamily(font.familyName).withSymbolicTraits(f.fontDescriptor.symbolicTraits)!
                let newFont = UIFont(descriptor: ufd, size: font.pointSize)
                removeAttribute(.font, range: range)
                removeAttribute(.foregroundColor, range: range)
                addAttribute(.font, value: newFont, range: range)
                addAttribute(.foregroundColor, value: color, range: range)
            }
        }
        endEditing()
    }
}

