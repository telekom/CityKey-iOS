/*
Created by Bharat Jagtap on 03/03/21.
Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Bharat Jagtap
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

protocol SCAusweisAuthEnterPinViewDisplay : SCAusweisAuthPINViewDisplay {
}

class SCAusweisAuthEnterPinViewController: UIViewController {
    
    private weak var pinViewController : SCAusweisAuthPINViewController!
    var presenter : SCAusweisAuthEnterPinPresenting!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupAccessibilityIDs()
        setupAccessibility()
        
        presenter.setDisplay(display: self)
        presenter.viewDidLoad()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SegueSCAusweisAuthPINViewController" {
            self.pinViewController = (segue.destination as! SCAusweisAuthPINViewController)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presenter.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        presenter.viewDidAppear()
    }
    
    func setupUI() {
        
        updateLabels()
    }
    
    private func updateLabels() {
        
        pinViewController.setHeader1(text: "egov_pin_info1".localized(), error: false)
        
        pinViewController.setHeader2(text: "", error: false)
                
        pinViewController.setPinHelpButtonTitle(title: "egov_pin_5digits_pin_label".localized())
        
        pinViewController.setNeedHelpButtonTitle(title: "egov_help_link_btn".localized())
        
        pinViewController.setSubmitButtonTitle(title: "egov_pin_submit_btn".localized())

    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){

    }

    private func setupAccessibility(){
        
        pinViewController.heading1.accessibilityLabel = "egov_pin_info1".localized()
        pinViewController.heading2.accessibilityLabel = ""
        pinViewController.pin5DigitButton.accessibilityLabel =  "egov_pin_5digits_pin_label".localized()
        pinViewController.helpButton.accessibilityLabel = "egov_help_link_btn".localized()
        pinViewController.submitPIN.accessibilityLabel = "egov_pin_title".localized()

    }
    
}

extension SCAusweisAuthEnterPinViewController : SCAusweisAuthEnterPinViewDisplay {
    
    var pin : String {
        get {
            return pinViewController.pin
        }
        set {
            pinViewController.pin = newValue
        }
    }
    
    func setHeader1(text : String, error : Bool) {
        pinViewController.setHeader1(text: text, error: error)
    }
    
    func setHeader2(text : String, error : Bool) {
        pinViewController.setHeader2(text: text, error: error)
    }
    
    func setNumberOfDigitsForPin(digits : Int) {
        pinViewController.setNumberOfDigitsForPin(digits: digits)
    }
    
    func setPinHelpButtonTitle(title : String) {
        pinViewController.setPinHelpButtonTitle(title: title)
    }
    
    func setNeedHelpButtonTitle(title : String) {
        pinViewController.setNeedHelpButtonTitle(title: title)
    }
    
    func setSubmitButtonTitle(title : String) {
        pinViewController.setSubmitButtonTitle(title: title)
    }

    func setIsPinInvalid(isPinInvalid : Bool) {
        pinViewController.setIsPinInvalid(isPinInvalid: isPinInvalid)
    }
    
    func setOnPinHelpButtonClick(_ onPinHelpButtonClick:@escaping ()->()) {
        pinViewController.setOnPinHelpButtonClick(onPinHelpButtonClick : onPinHelpButtonClick)
    }
    
    func setOnNeedHelpButtonClick(_ onNeedHelpButtonClick:@escaping ()->()) {
        pinViewController.setOnNeedHelpButtonClick(onNeedHelpButtonClick: onNeedHelpButtonClick)
    }
    
    func setOnSubmitButtonClick(_ onSubmitButtonClick:@escaping ()->()) {
        pinViewController.setOnSubmitButtonClick(onSubmitButtonClick: onSubmitButtonClick)
    }
    
    func hidePinHelpButton() {
        pinViewController.hidePinHelpButton()
    }
}
