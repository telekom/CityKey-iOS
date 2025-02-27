/*
Created by Michael on 28.11.18.
Copyright © 2018 Michael. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Copyright © 2018 Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

enum SCTextfieldValidationState {
    case unmarked
    case ok
    case warning
    case wrong
}

@objc protocol SCTextfieldComponentDelegate : NSObjectProtocol
{
    func textFieldComponentShouldReturn(component: SCTextfieldComponent) -> Bool
    func textFieldComponentEditingBegin(component: SCTextfieldComponent)
    func textFieldComponentDidChange(component: SCTextfieldComponent)
    func textFieldComponentEditingEnd(component: SCTextfieldComponent)
    @objc optional func datePickerDoneWasPressed()
//    @objc optional func datePickerNextWasPressed()
//    @objc optional func datePickerPreviousWasPressed()

}

class SCTextfieldComponent: UIViewController, UITextFieldDelegate, SCTextFieldConfigurable {

    @IBOutlet weak var textField: SCTextfieldWithoutCopy!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var validationStateImageView: UIImageView!
    
    @IBOutlet weak var seperatorView: UIView!
    
    weak var delegate:SCTextfieldComponentDelegate?
    
    private var enabled: Bool = true
    private var validationStateWidth : CGFloat!

    var disallowedCharacters: String = ""
    var placeholderText: String = ""
    var textfieldType : SCTextfieldComponentType = .text
    var maxCharCount : Int = 255
    var autoCapitalization: UITextAutocapitalizationType = .none
    
    var accessibilityIdentifier: String?{
        didSet {
            if accessibilityIdentifier != nil{
                self.actionButton?.accessibilityIdentifier = "btn_" + accessibilityIdentifier!
                self.textField?.accessibilityIdentifier = "txtfld_" + accessibilityIdentifier!
                self.errorLabel?.accessibilityIdentifier = "lbl_error_" + accessibilityIdentifier!
                self.placeholderLabel?.accessibilityIdentifier = "lbl_placeholder_" + accessibilityIdentifier!
                self.validationStateImageView?.accessibilityIdentifier = "img_" + accessibilityIdentifier!
            } else {
                self.actionButton?.accessibilityIdentifier = nil
                self.textField?.accessibilityIdentifier = nil
                self.errorLabel?.accessibilityIdentifier = nil
                self.placeholderLabel?.accessibilityIdentifier = nil
                self.validationStateImageView?.accessibilityIdentifier = nil
            }
        }
    }

    var showPwdSelected: Bool = false {
        didSet {
            if showPwdSelected {
                self.actionButton?.setImage(UIImage(named: "icon_showpass_selected")?.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!), for: .normal)
                self.textField?.isSecureTextEntry = false
            } else {
                self.actionButton?.setImage(UIImage(named: "icon_showpass_unselected")?.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!), for: .normal)
                self.textField?.isSecureTextEntry = true
            }
        }
    }

    var validationState: SCTextfieldValidationState = .unmarked {
        didSet {
            switch validationState {
            case .warning:
                self.validationStateImageView?.image = UIImage(named: "icon_val_warning")
                validationStateImageView.isHidden = false
                self.errorLabel.textColor = UIColor(named: "CLR_LABEL_TEXT_ORANGE")!
                self.seperatorView.backgroundColor = UIColor(named: "CLR_LABEL_TEXT_RED")!
            case .wrong:
                self.validationStateImageView?.image = UIImage(named: "icon_val_error")
                validationStateImageView.isHidden = false
                self.errorLabel.textColor = UIColor(named: "CLR_LABEL_TEXT_RED")!
                self.seperatorView.backgroundColor = UIColor(named: "CLR_LABEL_TEXT_RED")!
            case .ok:
                self.validationStateImageView?.image = UIImage(named: "icon_val_ok")
                validationStateImageView.isHidden = false
                self.seperatorView.backgroundColor = UIColor(named: "CLR_INPUT")!
            default:
                self.validationStateImageView?.image = nil
                validationStateImageView.isHidden = true
                self.seperatorView.backgroundColor = enabled ? UIColor(named: "CLR_INPUT")! : UIColor(named: "CLR_LABEL_TEXT_GRAY_GRAY")!
            }
            
            if self.textfieldType == .password || self.textfieldType == .newPassword {
                self.showActionButton()
            }

        }
    }

    
    var initialText: String? {
        didSet {
            self.textField?.text = initialText
            self.refreshTopPlaceholderLabel()
        }
    }
    
    var text: String? {
        get {
            return self.textField?.text
        }
        set(newVal) { //you can use any name for the passed parameter.Default is newValue
            self.textField?.text = newVal
        }
    }
    
    func configure(placeholder: String, fieldType: SCTextfieldComponentType, maxCharCount: Int, autocapitalization: UITextAutocapitalizationType) {
        self.placeholderText = placeholder
        self.textfieldType = fieldType
        self.maxCharCount = maxCharCount
        self.autoCapitalization = autocapitalization
        
        self.updatePlaceholder(text: self.placeholderText)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                if let image = self.actionButton?.image(for: .normal){
                    self.actionButton?.setImage(image.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!), for: .normal)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        hideActionButton()
        self.errorLabel.adaptFontSize()
        self.placeholderLabel.adaptFontSize()
        // Do any additional setup after loading the view.
        self.hideError()
        self.hideActionButton()
        self.textField.delegate = self
        self.textField?.attributedPlaceholder = self.placeholderText.applyHyphenation()
        self.placeholderLabel?.attributedText = self.placeholderText.applyHyphenation()
        self.placeholderLabel?.textColor = UIColor(named: "CLR_LABEL_TEXT_GRAY_GRAY")
        
        self.textField.autocapitalizationType = self.autoCapitalization

        self.updatePlaceholder(text: self.placeholderText)
        self.setTextfieldType(self.textfieldType)
        self.setMaxAllowedTextfieldCharacters(maxCharCount)
        
        self.textField?.text = self.initialText
        self.validationState = .unmarked
        self.setEnabled(self.enabled)
 
        self.refreshTopPlaceholderLabel()
        self.actionButton.accessibilityTraits = .button
        self.actionButton.accessibilityLabel = self.showPwdSelected ? "accessibility_btn_show_password".localized() : "accessibility_btn_hide_password".localized()
        self.actionButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }
    
    func updatePlaceholder(text: String){
        let fontSize : CGFloat = self.textField?.font?.pointSize ?? 0.0
        self.textField?.attributedPlaceholder = NSAttributedString(string: text, attributes: [
            .foregroundColor: UIColor.lightGray,
            .font: UIFont.boldSystemFont(ofSize: fontSize - 3.0)
            ])
        self.placeholderLabel?.attributedText = text.applyHyphenation()
        self.placeholderText = text
        
        self.placeholderLabel?.accessibilityLabel = placeholderLabel?.text
        self.placeholderLabel?.accessibilityTraits = .staticText
        self.placeholderLabel?.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        UIAccessibility.post(notification: .announcement, argument: placeholderLabel?.text)
    }
    
   func showError(message: String){
        self.errorLabel.isHidden = false
        self.errorLabel.text = message
        self.errorLabel.textColor = UIColor(named: "CLR_LABEL_TEXT_RED")!
        self.seperatorView.backgroundColor = UIColor(named: "CLR_LABEL_TEXT_RED")!
    
        let errorMsg = message != "r_001_registration_error_password_too_weak".localized() ? message : "accessibility_password_too_weak".localized()
        self.errorLabel.accessibilityLabel = errorMsg
        self.errorLabel.accessibilityTraits = .staticText
        self.errorLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        UIAccessibility.post(notification: .announcement, argument: errorMsg)
    }
    
    func show(message: String, color : UIColor){
        self.errorLabel.isHidden = false
        self.errorLabel.text = message
        self.errorLabel.textColor = color
        self.seperatorView.backgroundColor = color
        
        let errorMsg = message != "r_001_registration_hint_password_strong".localized() ? message : "accessibility_password_strong".localized()
        self.errorLabel.accessibilityLabel = errorMsg
        self.errorLabel.accessibilityTraits = .staticText
        self.errorLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        UIAccessibility.post(notification: .announcement, argument: errorMsg)
    }
    
    func hideError(){
        self.errorLabel.isHidden = true
        self.seperatorView.backgroundColor = enabled ? UIColor(named: "CLR_INPUT")! : UIColor(named: "CLR_LABEL_TEXT_GRAY_GRAY")!
    }
    
    func setLineColor(_ color : UIColor){
        self.seperatorView.backgroundColor = color
    }
    

    func resignResponder(){
        self.textField.resignFirstResponder()
    }

    func becomeResponder(){
        self.textField.becomeFirstResponder()
    }

    func textfieldFrame() -> CGRect{
        return self.view.superview?.frame ?? self.view.frame
    }

    func setTextfieldType(_ type : SCTextfieldComponentType){
        self.textfieldType = type
 
        self.textField?.keyboardType = .asciiCapable
        
        switch type {
        case .password:
            self.textField?.isSecureTextEntry = true
            self.showActionButton()
            self.showPwdSelected = false
            self.textField.textContentType = .password

        case .newPassword:
            self.textField?.isSecureTextEntry = true
            self.showActionButton()
            self.showPwdSelected = false
            self.textField.textContentType = .password
            if #available(iOS 12, *) {
                self.textField.textContentType = .newPassword
            }
        case .postalCode:
            self.textField?.keyboardType = .asciiCapableNumberPad
        case .email:
            self.textField.textContentType = .emailAddress
            self.textField.keyboardType = .emailAddress
            
        case .text:
            debugPrint("no special treatment for text at the moment, sorry!")
            
        case .wasteBinId:
            self.textField?.keyboardType = .asciiCapableNumberPad
        
        case .birthdate:
            self.textField.keyboardType = .numberPad
        }
    }
    
    
    
    func setMaxAllowedTextfieldCharacters(_ charCount : Int){
        self.maxCharCount = charCount
    }

    func maxAllowedTextfieldCharacters() -> Int{
        return self.maxCharCount
    }

    func isEnabled()-> Bool{
        return self.enabled
    }
    
    func setUppercaseStart() {
        self.textField?.autocapitalizationType = .words
    }

    func setEnabled(_ enabled : Bool) {
        self.enabled = enabled
        self.textField?.isEnabled = enabled
        self.textField?.textColor = enabled ? UIColor(named: "CLR_LABEL_TEXT_BLACK")! : UIColor(named: "CLR_LABEL_TEXT_GRAY_GRAY")!
        self.seperatorView?.backgroundColor = enabled ? UIColor(named: "CLR_INPUT")! : UIColor(named: "CLR_LABEL_TEXT_GRAY_GRAY")!

    }

    func deleteContent() {
        self.text = nil
        self.refreshTopPlaceholderLabel()
        self.hideError()
    }

    private func showActionButton(){
        self.actionButton?.isHidden = false
    }
    
    private func hideActionButton(){
        self.actionButton?.isHidden = true
    }

    private func refreshTopPlaceholderLabel(){
        self.placeholderLabel?.attributedText = self.placeholderText.applyHyphenation()
        self.placeholderLabel?.isHidden = self.textField.text?.isEmpty ?? true
    }
    
    //  UITextFieldDelegate methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textfieldType == .birthdate {
            guard let currentText = textField.text else { return true }
            // Check if the user is deleting
            if string.isEmpty {
                // If deleting and there's a '/' at the deletion point, delete it too
                if range.location == 3 || range.location == 6 {
                    textField.text = String(currentText.prefix(range.location - 1))
                } else {
                    textField.text = String(currentText.prefix(range.location)) + String(currentText.suffix(currentText.count - range.location - 1))
                }
                return false
            }
            
            // Handle input
            let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
            let filtered = updatedText.filter { "0123456789".contains($0) }
            
            if filtered.count > 8 {
                return false
            }
            
            var formatted = ""
            for (index, char) in filtered.enumerated() {
                if index == 2 || index == 4 {
                    formatted += "."
                }
                formatted += String(char)
            }
            
            textField.text = formatted
            if filtered.count == 8 {
                self.delegate?.textFieldComponentDidChange(component: self)
            }
            self.refreshTopPlaceholderLabel()
            return false
        }
        // for postal Code allow only numbers
        if (self.textfieldType == .postalCode || self.textfieldType == .wasteBinId) && !string.isNumber()  && string.count > 0 {
            return false
        }
        
        if string.rangeOfCharacter(from: CharacterSet(charactersIn: self.disallowedCharacters)) != nil{
            return false
        }
        
        // here we check only the max length
        guard let text = textField.text else { return true }
        let count = text.count + string.count - range.length
        return count <= self.maxCharCount
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return self.delegate?.textFieldComponentShouldReturn(component: self) ?? true
    }

    // TextField Actions
    @IBAction func textfieldEditingChanged(_ sender: Any) {
        
        self.refreshTopPlaceholderLabel()
        self.delegate?.textFieldComponentDidChange(component: self)
    }
    
    @IBAction func textfieldEditingBegin(_ sender: Any) {
        self.refreshTopPlaceholderLabel()
        self.delegate?.textFieldComponentEditingBegin(component: self)
    }
    
    @IBAction func textfieldEditingEnd(_ sender: Any) {
        self.delegate?.textFieldComponentEditingEnd(component: self)
        self.refreshTopPlaceholderLabel()
    }
    
    @objc func datePickerDoneWasPressed() {
        self.delegate?.datePickerDoneWasPressed?()
    }
    
    /// below callbacks are no more applications since the respective prev and next arrow buttons on the toolbar are removed
    /// should be cleaned up totally in future with code cleaning
    /*
    @objc func datePickerNextWasPressed() {
        self.delegate?.datePickerNextWasPressed?()
    }
    @objc func datePickerPreviousWasPressed() {
        self.delegate?.datePickerPreviousWasPressed?()
    }
    */
    
    @objc func datePickerClearWasPressed() {
       
        self.textField.text = nil
        self.refreshTopPlaceholderLabel()
        self.delegate?.textFieldComponentDidChange(component: self)
    }
    
    // Handling the action button
    @IBAction func actionBtnWasPressed(_ sender: Any) {
        self.showPwdSelected = !self.showPwdSelected
        self.actionButton.accessibilityTraits = .button
        self.actionButton.accessibilityLabel = self.showPwdSelected ? "accessibility_btn_show_password".localized() : "accessibility_btn_hide_password".localized()
        self.actionButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()

    }
    
    
    //
    // Datepicker delegate method
    //
    
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        self.textField.text = birthdayStringFromDate(birthdate: sender.date)
        self.refreshTopPlaceholderLabel()
        self.delegate?.textFieldComponentDidChange(component: self)

    }

}

