/*
Created by Rutvik Kanbargi on 17/07/20.
Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Rutvik Kanbargi
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

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
