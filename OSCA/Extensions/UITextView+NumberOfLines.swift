//
//  UITextView+NumberOfLines.swift
//  OSCA
//
//  Created by Michael on 03.06.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

extension UITextView {
    var maxNumberOfLines: Int {
        let layoutManager = self.layoutManager
        let numberOfGlyphs = layoutManager.numberOfGlyphs
        var lineRange: NSRange = NSMakeRange(0, 1)
        var index = 0
        var numberOfLines = 0

        while index < numberOfGlyphs {
            layoutManager.lineFragmentRect(
                forGlyphAt: index, effectiveRange: &lineRange
            )
            index = NSMaxRange(lineRange)
            numberOfLines += 1
        }
        return numberOfLines
    }
    
    var isTextTruncated: Bool {
      var isTruncating = false

      // The `truncatedGlyphRange(...) method will tell us if text has been truncated
      // based on the line break mode of the text container
      layoutManager.enumerateLineFragments(forGlyphRange: NSRange(location: 0, length: Int.max)) { _, _, _, glyphRange, stop in
        let truncatedRange = self.layoutManager.truncatedGlyphRange(inLineFragmentForGlyphAt: glyphRange.lowerBound)
        if truncatedRange.location != NSNotFound {
          isTruncating = true
          stop.pointee = true
        }
      }

      // It's possible that the text is truncated not because of the line break mode,
      // but because the text is outside the drawable bounds
      if isTruncating == false {
        let glyphRange = layoutManager.glyphRange(for: textContainer)
        let characterRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)

        isTruncating = characterRange.upperBound < text.utf16.count
      }

      return isTruncating
   }
}
