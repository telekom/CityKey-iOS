/*
Created by Bharat Jagtap on 01/03/21.
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

protocol SCAusweisAuthPINViewDisplay : SCDisplaying, AnyObject {
    
    func setHeader1(text : String, error : Bool)
    func setHeader2(text : String, error : Bool)
    func setNumberOfDigitsForPin(digits : Int)
    func setPinHelpButtonTitle(title : String)
    func setNeedHelpButtonTitle(title : String)
    func setSubmitButtonTitle(title : String)
    func setIsPinInvalid(isPinInvalid : Bool)
    func setOnPinHelpButtonClick(_ onPinHelpButtonClick:@escaping ()->())
    func setOnNeedHelpButtonClick(_ onNeedHelpButtonClick:@escaping ()->())
    func setOnSubmitButtonClick(_ onSubmitButtonClick:@escaping ()->())
    var pin : String { get set }
    func hidePinHelpButton()
}


class SCAusweisAuthPINViewController: UIViewController {
    
    @IBOutlet weak var btn0 : UIButton!
    @IBOutlet weak var btn1 : UIButton!
    @IBOutlet weak var btn2 : UIButton!
    @IBOutlet weak var btn3 : UIButton!
    @IBOutlet weak var btn4 : UIButton!
    @IBOutlet weak var btn5 : UIButton!
    @IBOutlet weak var btn6 : UIButton!
    @IBOutlet weak var btn7 : UIButton!
    @IBOutlet weak var btn8 : UIButton!
    @IBOutlet weak var btn9 : UIButton!
    @IBOutlet weak var btnClear : UIButton!
    @IBOutlet weak var btnEye : UIButton!
    @IBOutlet weak var pinView : SCPinView!
    @IBOutlet weak var heading1 : UILabel!
    @IBOutlet weak var heading2 : UILabel!
    @IBOutlet weak var pin5DigitButton : UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var submitPIN : SCCustomButton!
    
    @IBOutlet weak var pin5DigitButtonHeightConstraint: NSLayoutConstraint!    
    @IBOutlet weak var pin5DigitButtonTopSpaceConstraint: NSLayoutConstraint!
    
    private var onPinHelpButtonClick : ()->()? = ({})
    private var onNeedHelpButtonClick: ()->()? = ({})
    private var onSubmitButtonClick: ()->()? = ({})
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAccessibilityIDs()
        setupAccessibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupUI()
    }
    
    func setupUI() {
        
        let digitButtons = [btn0, btn1, btn2, btn3, btn4, btn5, btn6, btn7, btn8, btn9]
        for btn in digitButtons {
            
            btn?.layer.cornerRadius = ( btn?.frame.size.width ??  60.0 ) / 2
            btn?.clipsToBounds = true
            btn?.layer.borderWidth = 2.0
            btn?.layer.borderColor = UIColor.labelTextBlackCLR.cgColor
            btn?.setTitleColor(UIColor.labelTextBlackCLR, for: .normal)
            btn?.titleLabel?.adjustsFontForContentSizeCategory = true
            btn?.titleLabel?.font = UIFont.SystemFont.medium.forTextStyle(style: .title2, size: 24.0, maxSize: nil)
        }
        
        self.submitPIN.customizeAusweisBlueStyle()
        maskImagesForCurrentTraitCollection()
        
        heading1.adjustsFontForContentSizeCategory = true
        heading1.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)

        heading2.adjustsFontForContentSizeCategory = true
        heading2.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)

        pin5DigitButton.titleLabel?.adjustsFontForContentSizeCategory = true
        pin5DigitButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .subheadline, size: 14.0, maxSize: 25)

        helpButton.titleLabel?.adjustsFontForContentSizeCategory = true
        helpButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .subheadline, size: 14.0, maxSize: 25)
        
        submitPIN.titleLabel?.adjustsFontForContentSizeCategory = true
        submitPIN.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 18.0, maxSize: nil)

    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.heading1.accessibilityIdentifier = "lbl_Heading1"
        self.heading2.accessibilityIdentifier = "lbl_Heading2"
        self.btn0.accessibilityIdentifier = "btn_0"
        self.btn1.accessibilityIdentifier = "btn_1"
        self.btn2.accessibilityIdentifier = "btn_2"
        self.btn3.accessibilityIdentifier = "btn_3"
        self.btn4.accessibilityIdentifier = "btn_4"
        self.btn5.accessibilityIdentifier = "btn_5"
        self.btn6.accessibilityIdentifier = "btn_6"
        self.btn7.accessibilityIdentifier = "btn_7"
        self.btn8.accessibilityIdentifier = "btn_8"
        self.btn9.accessibilityIdentifier = "btn_9"
        self.btnEye.accessibilityIdentifier = "btn_Eye"
        self.btnClear.accessibilityIdentifier = "btn_Clear"
        self.submitPIN.accessibilityIdentifier = "btn_SubmitPIN"
        self.pinView.accessibilityIdentifier = "pinView"
        
    }
    
    private func setupAccessibility(){
        
        self.heading1.accessibilityTraits = .staticText
        self.heading1.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.heading2.accessibilityTraits = .staticText
        self.heading2.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.btn0.accessibilityLabel = "0"
        self.btn0.accessibilityTraits = .button
        self.btn0.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.btn1.accessibilityLabel = "1"
        self.btn1.accessibilityTraits = .button
        self.btn1.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.btn2.accessibilityLabel = "2"
        self.btn2.accessibilityTraits = .button
        self.btn2.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.btn3.accessibilityLabel = "3"
        self.btn3.accessibilityTraits = .button
        self.btn3.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.btn4.accessibilityLabel = "4"
        self.btn4.accessibilityTraits = .button
        self.btn4.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.btn5.accessibilityLabel = "5"
        self.btn5.accessibilityTraits = .button
        self.btn5.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.btn6.accessibilityLabel = "6"
        self.btn6.accessibilityTraits = .button
        self.btn6.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.btn7.accessibilityLabel = "7"
        self.btn7.accessibilityTraits = .button
        self.btn7.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.btn8.accessibilityLabel = "8"
        self.btn8.accessibilityTraits = .button
        self.btn8.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.btn9.accessibilityLabel = "9"
        self.btn9.accessibilityTraits = .button
        self.btn9.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.btnEye.accessibilityLabel = "egov_accessibility_text_eye_button".localized()
        self.btnEye.accessibilityTraits = .button
        self.btnEye.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.btnClear.accessibilityLabel = "egov_accessibility_text_clear_button".localized()
        self.btnClear.accessibilityTraits = .button
        self.btnClear.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.submitPIN.accessibilityTraits = .button
        self.submitPIN.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.pinView.accessibilityTraits = .updatesFrequently
        self.pinView.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        maskImagesForCurrentTraitCollection()
    }
    
    func maskImagesForCurrentTraitCollection() {
        
        if #available(iOS 13.0, *) {
            
            if let eyeImage = self.btnEye?.image(for: .normal){
                self.btnEye?.setImage(eyeImage.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!), for: .normal)
            }
            if let clearImage = self.btnClear?.image(for: .normal){
                self.btnClear?.setImage(clearImage.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!), for: .normal)
            }
        }
    }
    
    @IBAction func digitPressed(_ sender : UIButton) {
        var digit = -1
        switch sender {
        case btn0:
            digit = 0
        case btn1:
            digit = 1
        case btn2:
            digit = 2
        case btn3:
            digit = 3
        case btn4:
            digit = 4
        case btn5:
            digit = 5
        case btn6:
            digit = 6
        case btn7:
            digit = 7
        case btn8:
            digit = 8
        case btn9:
            digit = 9
        default:
            digit = -1
        }
        
        guard digit != -1 else {
            return
        }
        
        pinView.addDigit(digit: Character("\(digit)"))
        
    }
    
    @IBAction func clearClicked(_ sender : UIButton) {
        pinView.removeLast()
    }
    
    @IBAction func toggleVisibilityClicked(_ sender : UIButton) {
        
        pinView.isPinVisible = !pinView.isPinVisible
        self.btnEye.setImage(UIImage(named: pinView.isPinVisible ? "eid_eye_logo_fill" : "eid_eye_logo_outline" ), for: .normal)
        if let eyeImage = self.btnEye?.image(for: .normal){
            self.btnEye?.setImage(eyeImage.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!), for: .normal)
        }

    }
    
    @IBAction func needPinHelpClicked(_ sender : UIButton) {
        
        self.onPinHelpButtonClick()        
    }
    
    @IBAction func needHelpClicked(_ sender : UIButton) {
        
        self.onNeedHelpButtonClick()
    }
    
    @IBAction func submitClicked(_ sender : UIButton) {
        
        self.onSubmitButtonClick()
    }
    
}

extension SCAusweisAuthPINViewController {
    
    var pin : String {
        get {
            return pinView.pin
        }
        set {
            pinView.pin = newValue
        }
    }
    
    func setHeader1(text : String, error : Bool) {
        
        heading1.text = text
        heading1.textColor = error ? UIColor.systemRed : UIColor.labelTextBlackCLR
        heading1.accessibilityLabel = text
    }
    
    func setHeader2(text : String, error : Bool) {
        
        heading2.text = text
        heading2.textColor = error ? UIColor.systemRed : UIColor.labelTextBlackCLR
        heading2.accessibilityLabel = text
    }
    
    func setNumberOfDigitsForPin(digits : Int) {
        pinView.numberOfDigits = digits
    }
    
    func setPinHelpButtonTitle(title : String) {
        pin5DigitButton.setTitle(title, for: .normal)
    }
    
    func setNeedHelpButtonTitle(title : String) {
        helpButton.setTitle(title, for: .normal)
    }
    
    func setSubmitButtonTitle(title : String) {
        
        submitPIN.setTitle(title, for: .normal)
        submitPIN.accessibilityLabel = title
    }
    
    func setIsPinInvalid(isPinInvalid : Bool) {
        pinView.isInvalid = isPinInvalid
    }
    
    func setOnPinHelpButtonClick(onPinHelpButtonClick:@escaping ()->()) {
        self.onPinHelpButtonClick = onPinHelpButtonClick
    }
    
    func setOnNeedHelpButtonClick(onNeedHelpButtonClick:@escaping ()->()) {
        
        self.onNeedHelpButtonClick = onNeedHelpButtonClick
    }
    
    func setOnSubmitButtonClick(onSubmitButtonClick:@escaping ()->()) {
        
        self.onSubmitButtonClick = onSubmitButtonClick
    }
    
    func hidePinHelpButton() {
        
        self.pin5DigitButtonHeightConstraint.constant = 0
        self.pin5DigitButtonTopSpaceConstraint.constant = 0
        self.pin5DigitButton.setTitle("", for: .normal)
        self.pin5DigitButton.isHidden = true
    }
}
