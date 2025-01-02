//
//  SCLabelWithLinks.swift
//  SmartCity
//
//  Created by Robert Swoboda on 26.03.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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

