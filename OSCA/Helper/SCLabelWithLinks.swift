/*
Created by Robert Swoboda on 26.03.19.
Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Robert Swoboda
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

// base on https://stackoverflow.com/questions/1256887/create-tap-able-links-in-the-nsattributedstring-of-a-uilabel

import UIKit

protocol LabelLinkDelegate: AnyObject {
    func linkWasTapped(label: SCLabelWithLinks)
    func baseTextWasTapped(label: SCLabelWithLinks)
}

class SCLabelWithLinks: SCTopAlignLabel {
    public weak var labelLinkDelegate: LabelLinkDelegate?
    
    private var layoutManager: NSLayoutManager?
    private var textContainer: NSTextContainer?
    private var textStorage: NSTextStorage?
    
    private var linkRange: NSRange = NSMakeRange(0, 0)
    
    override func layoutSubviews() {
        self.textContainer?.size = self.bounds.size
    }
    
    func configureText(baseText: String, linkText: String) {
        
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOnText(tapRecognizer:))))
        
        let baseText = baseText.replacingOccurrences(of: "%s", with: "%@")

        let baseString: NSString = NSString(string: baseText)
        let combinedString = String(format: baseText, linkText)
        
        let startLoc = baseString.range(of: "%@").location
        self.linkRange = NSMakeRange(startLoc, linkText.count)
        
        let attributedString = NSMutableAttributedString(string: combinedString)
        let linkAttributes: [NSAttributedString.Key : Any]
            = [NSAttributedString.Key.foregroundColor: UIColor(named: "CLR_OSCA_BLUE")!]
        attributedString.setAttributes(linkAttributes, range: linkRange)
        
        // setup the layout system
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: attributedString)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = 0.0;
        textContainer.lineBreakMode = self.lineBreakMode;
        textContainer.maximumNumberOfLines = self.numberOfLines;
        
        self.attributedText = attributedString
        
        // save the layout objects for later use
        self.layoutManager = layoutManager
        self.textContainer = textContainer
        self.textStorage = textStorage
    }
    
    @objc func tapOnText(tapRecognizer: UITapGestureRecognizer) {
        
        guard let textContainer = self.textContainer  else {
            debugPrint("SCLabelWithLinks: no textContainer to search for tapped chars")
            return
        }
        guard let layoutManager = self.layoutManager  else {
            debugPrint("SCLabelWithLinks: no layoutManager to search for tapped chars")
            return
        }
        
        let locOfTouchInLabel = tapRecognizer.location(in: tapRecognizer.view)
        
        let indexOfCharacter
            = layoutManager.characterIndex(for: locOfTouchInLabel,
                                           in: textContainer,
                                           fractionOfDistanceBetweenInsertionPoints: nil)
        // make the clickable are one char larger
        // to avoid user frustration
        let expandedRange = NSMakeRange(self.linkRange.location,
                                        self.linkRange.length+2)
        
        if (NSLocationInRange(indexOfCharacter, expandedRange)) {
            self.labelLinkDelegate?.linkWasTapped(label: self)
        }
        else{
            self.labelLinkDelegate?.baseTextWasTapped(label: self)
        }
    }
}

