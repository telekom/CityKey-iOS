//
//  SCTextfieldWithoutCopy.swift
//  SmartCity
//
//  Created by Michael on 18.07.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCTextfieldWithoutCopy: UITextField {

    
    open override func target(forAction action: Selector, withSender sender: Any?) -> Any? {

        if self.isSecureTextEntry {
            if action == #selector(UIResponderStandardEditActions.copy(_:)) {
                return nil
            }
        }
        return super.target(forAction: action, withSender: sender)
        
    }
}
