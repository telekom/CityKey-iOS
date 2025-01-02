//
//  SCDynamicFontHelper.swift
//  OSCA
//
//  Created by A118572539 on 21/07/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

extension UIFont {
    
    enum SystemFont : String {
        
        case regular = "SFPro"
        case bold = "SFPro-Bold"
        case medium = "SFPro-Medium"
        case light = "SFPro-Light"
        case italic = "SFPro-Italic"
        
        func forTextStyle(style: UIFont.TextStyle ,size : CGFloat, maxSize : CGFloat?) -> UIFont {
            switch self {
            case .regular:
                let font = UIFont.systemFont(ofSize: size, weight: UIFont.Weight.regular)
                return font.scaledFont(forStyle: style, size: size, maxSize: maxSize)
            case .bold:
                let font = UIFont.systemFont(ofSize: size, weight: UIFont.Weight.bold)
                return font.scaledFont(forStyle: style, size: size, maxSize: maxSize)
            case .light:
                let font = UIFont.systemFont(ofSize: size, weight: UIFont.Weight.light)
                return font.scaledFont(forStyle: style, size: size, maxSize: maxSize)
            case .italic:
                let font = UIFont.italicSystemFont(ofSize: size)
                return font.scaledFont(forStyle: style, size: size, maxSize: maxSize)
            case .medium:
                let font = UIFont.systemFont(ofSize: size, weight: UIFont.Weight.medium)
                return font.scaledFont(forStyle: style, size: size, maxSize: maxSize)
            }
        }
    }
    
    private func scaledFont(forStyle style: UIFont.TextStyle, size : CGFloat, maxSize: CGFloat?) -> UIFont {
        return (maxSize != nil) ? UIFontMetrics(forTextStyle: style).scaledFont(for: self, maximumPointSize: maxSize!) :UIFontMetrics(forTextStyle: style).scaledFont(for: self)
    }
}
