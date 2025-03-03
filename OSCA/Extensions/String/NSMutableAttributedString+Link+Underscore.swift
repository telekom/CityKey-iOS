/*
Created by Michael on 03.12.18.
Copyright © 2018 Michael. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 
In accordance with Sections 4 and 6 of the License, the following exclusions apply:

    1. Trademarks & Logos – The names, logos, and trademarks of the Licensor are not covered by this License and may not be used without separate permission.
    2. Design Rights – Visual identities, UI/UX designs, and other graphical elements remain the property of their respective owners and are not licensed under the Apache License 2.0.
    3: Non-Coded Copyrights – Documentation, images, videos, and other non-software materials require separate authorization for use, modification, or distribution.

These elements are not considered part of the licensed Work or Derivative Works unless explicitly agreed otherwise. All elements must be altered, removed, or replaced before use or distribution. All rights to these materials are reserved, and Contributor accepts no liability for any infringing use. By using this repository, you agree to indemnify and hold harmless Contributor against any claims, costs, or damages arising from your use of the excluded elements.

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Copyright © 2018 Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

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

