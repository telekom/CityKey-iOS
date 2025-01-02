//
//  SCTextFieldConfigurable.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 23.04.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

protocol SCTextFieldConfigurable: AnyObject {
    func configure(placeholder: String, fieldType: SCTextfieldComponentType, maxCharCount: Int, autocapitalization: UITextAutocapitalizationType)
    func configure(placeholder: String, fieldType: SCTextfieldComponentType, maxCharCount: Int, autocapitalization: UITextAutocapitalizationType, disclaimerText: String?)
    func setEnabled(_ enabled : Bool)
}

extension SCTextFieldConfigurable {
    //optinal method with no implementation
    func configure(placeholder: String, fieldType: SCTextfieldComponentType, maxCharCount: Int, autocapitalization: UITextAutocapitalizationType, disclaimerText: String?) {

    }
}
