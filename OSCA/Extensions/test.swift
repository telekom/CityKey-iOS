//
//  test.swift
//  SmartCity
//
//  Created by Michael on 15.03.19.
//  Copyright © 2019 Michael. All rights reserved.
//

import UIKit

private var hideableUIViewConstraintsKey: UInt8 = 0

extension UIView {
    
    private var _parentConstraintsReference: [AnyObject]! {
        get {
            return objc_getAssociatedObject(self, &hideableUIViewConstraintsKey) as? [AnyObject] ?? []
        }
        set {
            objc_setAssociatedObject(self, &hideableUIViewConstraintsKey, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
        }
    }
    
    func hideView() {
        self.isHidden = true
        
        if let parentView = self.superview where _parentConstraintsReference.count == 0 {
            //get the constraints that involve this view to re-add them when the view is shown
            if let parentConstraints = parentView.constraints as? [NSLayoutConstraint] {
                for parentConstraint in parentConstraints {
                    if parentConstraint.firstItem === self || parentConstraint.secondItem === self {
                        _parentConstraintsReference.append(parentConstraint)
                    }
                }
            }
            
            parentView.removeConstraints(_parentConstraintsReference as! [NSLayoutConstraint])
        }
    }
    
    func showView() {
        //reapply any previously existing constraints
        if let parentView = self.superview {
            parentView.addConstraints(_parentConstraintsReference as! [NSLayoutConstraint])
        }
        
        _parentConstraintsReference = []
        self.isHidden = false
    }
}
