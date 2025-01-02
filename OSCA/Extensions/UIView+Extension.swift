//
//  UIView+Extension.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 17/07/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

extension UIView {
    
    func addCornerRadius(radius: CGFloat = 6.0) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
    
    func addShadow(shadowColor: UIColor = UIColor(named: "CLR_BORDER_SILVERGRAY")!,
                   shadowOffset: CGSize = CGSize(width: 3, height: 3),
                   shadowOpacity: Float = 0.4,
                   shadowRadius: CGFloat = 3.0) {
        layer.backgroundColor = UIColor.clear.cgColor
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
    
    func addBorder(width: CGFloat = 1.0, color: UIColor = .gray) {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11.0, *) {
            clipsToBounds = true
            layer.cornerRadius = radius
            layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
        } else {
            let path = UIBezierPath(
                roundedRect: bounds,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            )
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    }
}


extension UIView {
    
    /// Find the first subview of the specified class.
    /// - Parameter className: The class name to search for.
    /// - Parameter usingRecursion: True if the search should continue through the subview tree until a match is found; false otherwise
    /// - Returns: The first child UIView of the specified class
    func findSubview(withClassName className: String, usingRecursion: Bool) -> UIView? {
        // If we can convert the class name until a class, we look for a match in the subviews of our current view
        if let reflectedClass = NSClassFromString(className) {
            for subview in self.subviews {
                if subview.isKind(of: reflectedClass) {
                    return subview
                }
            }
        }
        
        // If recursion was specified, we'll continue into all subviews until a view is found
        if usingRecursion {
            for subview in self.subviews {
                if let tempView = subview.findSubview(withClassName: className, usingRecursion: usingRecursion) {
                    return tempView
                }
            }
        }
        
        // If we haven't returned yet, there was no match
        return nil
    }
}
