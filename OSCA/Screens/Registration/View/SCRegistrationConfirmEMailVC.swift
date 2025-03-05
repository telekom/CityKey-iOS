/*
Created by Michael on 13.05.20.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

class SCRegistrationConfirmEMailVC: UIViewController, UITextFieldDelegate {
    

    public var presenter: SCRegistrationConfirmEMailPresenting!

    
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var resentLabelTopSpaceStackView: NSLayoutConstraint!
    @IBOutlet weak var resentLabel: UILabel!
    @IBOutlet weak var resentBtn: UIButton!
    @IBOutlet var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var confirmBtn: SCCustomButton!
    @IBOutlet weak var contentScrollview: UIScrollView!
    @IBOutlet weak var digitView: UIView!
    @IBOutlet var titleTopSpaceToNotificationViewConstratint: NSLayoutConstraint!
    @IBOutlet weak var validationStateImageView: UIImageView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var topImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var confirmButtonHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var topImageSymbolView: UIImageView!
    
    enum SCRegistrationConfirmEMailValidationState {
        case unmarked
        case ok
        case warning
        case wrong
    }

    var validationState: SCRegistrationConfirmEMailValidationState = .unmarked {
        didSet {
            switch validationState {
            case .warning:
                self.validationStateImageView?.image = UIImage(named: "icon_val_warning")
                self.errorLabel.textColor = UIColor(named: "CLR_LABEL_TEXT_ORANGE")!
            case .wrong:
                self.validationStateImageView?.image = UIImage(named: "icon_val_error")
                self.errorLabel.textColor = UIColor(named: "CLR_LABEL_TEXT_RED")!
            case .ok:
                self.validationStateImageView?.image = UIImage(named: "icon_val_ok")
            default:
                self.validationStateImageView?.image = nil
            }
            
        }
    }

    @IBOutlet var digitLabels: [UILabel]!{
        didSet {
            digitLabels.sort { $0.tag < $1.tag }
        }
    }
    
    @IBOutlet var digitUnderscoreViews: [UIView]!{
        didSet {
            digitUnderscoreViews.sort { $0.tag < $1.tag }
        }
    }
    
    @IBOutlet var digitUnderscoreViewHeightConstraints: [NSLayoutConstraint]!{
        didSet {
            digitUnderscoreViewHeightConstraints.sort { ($0.identifier!) < ($1.identifier!) }
        }
    }
    
    @IBOutlet weak var pinTextField: UITextField!
    private let keyboardOffsetSpace : CGFloat = 35.0
    private var keyboardHeight : CGFloat = 0.0

    
    public var registeredEmail: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupAccessibilityIDs()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification , object: nil)

        self.shouldNavBarTransparent = false

        self.notificationLabel.adaptFontSize()
        self.titleLabel.adaptFontSize()
        self.titleLabel.text = nil
        self.detailLabel.adaptFontSize()
        self.resentLabel.adaptFontSize()
        self.resentLabel.text = "r_004_registration_confirmation_info_not_received".localized()
        self.resentBtn.setTitle(" " + "r_004_registration_confirmation_btn_resend".localized(), for: .normal)
        self.resentBtn.titleLabel?.adaptFontSize()
        self.resentBtn.setImage(UIImage(named: "action_resend_email")?.maskWithColor(color: UIColor(named: "CLR_OSCA_BLUE")!), for: .normal)

        self.errorLabel.text = nil
        self.validationState = .unmarked
 
        self.notificationView.isHidden = true
        
        self.titleTopConstraint.constant = 20.0
        self.titleTopSpaceToNotificationViewConstratint.isActive = false
        confirmBtn.customizeBlueStyle()
        self.confirmBtn.setTitle("r_004_registration_confirmation_confirm_btn".localized(), for: .normal)
        self.confirmBtn.titleLabel?.adaptFontSize()
        self.confirmBtn.isHidden = true
        
        self.pinTextField.keyboardType = .asciiCapableNumberPad
        self.pinTextField.delegate = self
        self.pinTextField.becomeFirstResponder()

        self.clearAllDigits()
        self.refreshConformBtnState()
        
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
        handleDynamicTypeChange()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(digitPressed))
        
        digitView.addGestureRecognizer(gestureRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDynamicTypeChange), name: UIContentSizeCategory.didChangeNotification, object: nil)

    }
    
    @objc private func digitPressed() {
        showKeyboard()
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.notificationLabel.accessibilityIdentifier = "lbl_notification"
        self.confirmBtn.accessibilityIdentifier = "btn_confirm"
        self.titleLabel.accessibilityIdentifier = "lbl_title"
        self.detailLabel.accessibilityIdentifier = "lbl_detail"
        self.resentLabel.accessibilityIdentifier = "lbl_resent"
        self.resentBtn.accessibilityIdentifier = "btn_resent"
        self.errorLabel.accessibilityIdentifier = "lbl_error"
        self.validationStateImageView.accessibilityIdentifier = "img_state"

        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }
    
    @objc private func handleDynamicTypeChange() {
        notificationLabel.adjustsFontForContentSizeCategory = true
        notificationLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 18, maxSize: nil)
        detailLabel.adjustsFontForContentSizeCategory = true
        detailLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 14, maxSize: nil)
        errorLabel.adjustsFontForContentSizeCategory = true
        errorLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        resentLabel.adjustsFontForContentSizeCategory = true
        resentLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 14, maxSize: nil)
        resentBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        resentBtn.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: 20)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showKeyboard()

        self.refreshNavigationBarStyle()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    /**
     *
     * Handle Keyboard
     *
     */
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let height = keyboardFrame.height + keyboardOffsetSpace
        self.keyboardHeight = height
        
        self.contentScrollview.contentInset.bottom = height
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        self.contentScrollview.contentInset.bottom = 0.0
        self.contentScrollview.contentOffset = CGPoint(x: 0, y: 0)
    }

    //  UITextFieldDelegate methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if !string.isNumber()  && string.count > 0 {
            return false
        }

        let maxCharCount = digitLabels.count

        // here we check only the max length
        guard let text = textField.text else { return true }
        let count = text.count + string.count - range.length
        return count <= maxCharCount
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }

    @IBAction func pinTextFieldDidChange(_ sender: Any) {
        let maxDigitCount = digitLabels.count
        
        self.clearAllDigits()
        self.hidePinError()
        if let currentPin =  self.pinTextField.text {
            
            var underscoreActiveIndex = currentPin.count > maxDigitCount - 1 ? maxDigitCount - 1 : currentPin.count
            underscoreActiveIndex = underscoreActiveIndex < 0 ? 0 : underscoreActiveIndex
            
            self.digitUnderscoreViews[underscoreActiveIndex].backgroundColor = UIColor(named: "CLR_INPUT_FOCUS")!
            self.digitUnderscoreViewHeightConstraints[underscoreActiveIndex].constant = 2
            
            if currentPin.count-1  >= 0 {
                for i in 0...currentPin.count-1
                {
                    let index = currentPin.index(currentPin.startIndex, offsetBy: i)
                    self.digitLabels[i].text = String(currentPin[index])
                 }
            }
            
        } else {
            self.digitUnderscoreViews[0].backgroundColor = UIColor(named: "CLR_INPUT_FOCUS")!
            self.digitUnderscoreViewHeightConstraints[0].constant = 2
        }
        self.refreshConformBtnState()

    }
    
    private func clearAllDigits(){
        // clear all digit field
        let maxDigitCount = digitLabels.count

        for i in 0...maxDigitCount-1
        {
            self.digitLabels[i].text = ""
            self.digitUnderscoreViews[i].backgroundColor = UIColor(named: "CLR_INPUT")!
            self.digitUnderscoreViewHeightConstraints[i].constant = 1
        }
    }
    
    private func marksAllDigitsAsError(){
        // clear all digit field
        let maxDigitCount = digitLabels.count

        for i in 0...maxDigitCount-1
        {
            self.digitUnderscoreViews[i].backgroundColor = UIColor(named: "CLR_LABEL_TEXT_RED")!
            self.digitUnderscoreViewHeightConstraints[i].constant = 1
        }
    }
    
    private func refreshConformBtnState(){
        let maxDigitCount = digitLabels.count
        
        self.confirmBtn.btnState = maxDigitCount ==  self.pinTextField.text?.count ? .normal : .disabled
        if maxDigitCount ==  self.pinTextField.text?.count && self.confirmBtn.isHidden {
            self.presenter.confirmWasPressed()
        }
    }
    
    @IBAction func resentBtnWasPressed(_ sender: Any) {
        self.presenter.resendWasPressed()
    }
    
    @IBAction func confirmBtnWasPressed(_ sender: Any) {
        self.confirmBtn.btnState = .progress
        
        self.presenter.confirmWasPressed()
    }
    
    @IBAction func cancelBtnWasPressed(_ sender: Any) {
        self.presenter.cancelWasPressed()
    }
}


extension SCRegistrationConfirmEMailVC: SCRegistrationConfirmEMailDisplaying {
    
    func setupUIWithTitleText(titleText: String, topText: String, detailText: String, topImageSymbol: UIImage) {
        let attributedString = NSMutableAttributedString(string: topText)
        _ = attributedString.setAsBoldFont(textToFind: self.registeredEmail, fontSize: self.titleLabel.font.pointSize)
        
        self.titleLabel.attributedText = attributedString
        self.detailLabel.text = detailText
        self.navigationItem.title = titleText
        self.topImageSymbolView.image = topImageSymbol
        self.view.setNeedsLayout()
    }

    func hideConfirmButton() {
        self.confirmButtonHeightConstraint.constant = 0.0
        self.confirmBtn.isHidden = true
    }
    
    func hideTopImage() {
        self.topImageHeightConstraint.constant = 0.0
        self.topImageView.isHidden = true
        self.topImageSymbolView.isHidden = true
    }

    func disableResendButton(disable: Bool) {
        self.resentBtn.isEnabled = !disable
        self.resentBtn.setTitleColor(UIColor(named: "CLR_BUTTON_GREY_DISABLED"), for: .normal)
        self.resentBtn.setImage(UIImage(named: "action_resend_email")?.maskWithColor(color: UIColor(named: "CLR_BUTTON_GREY_DISABLED")!), for: .normal)
    }
    
    func displayResendFinished(message : String, textColor : UIColor){
        
        self.notificationLabel.text = message
        self.notificationLabel.textColor = textColor
        
        self.notificationView.isHidden = false
        titleTopConstraint.isActive = false
        titleTopSpaceToNotificationViewConstratint.isActive = true
        //  self.titleTopConstraint.constant = 70.0
        self.view.layoutIfNeeded()
    }

    func displayPinError(message : String){
        self.errorLabel.text = message
        self.validationState = .wrong
        self.marksAllDigitsAsError()
        resentLabelTopSpaceStackView.constant = errorLabel.frame.height + 60
        view.layoutIfNeeded()
    }

    func hidePinError(){
        self.errorLabel.text = ""
        self.validationState = .unmarked
        self.clearAllDigits()
        resentLabelTopSpaceStackView.constant = 60
        view.layoutIfNeeded()
    }
    
    func disableConfirmBtn(disable: Bool){
        self.confirmBtn.btnState = disable ? .disabled : .normal
    }

    
    func clearPinField(){
        self.pinTextField.text = ""
        self.hidePinError()
        self.clearAllDigits()
        self.refreshConformBtnState()
    }

    func showKeyboard(){
        self.pinTextField.becomeFirstResponder()
    }

    func hideKeyboard(){
        self.pinTextField.resignFirstResponder()
    }

    func overlay(viewController: UIViewController) {
        configureChildViewController(childController: viewController, onView: self.view)
    }
    
    func push(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func present(viewController: UIViewController) {
        self.present(viewController, animated: true)
    }

    func dismiss(){
        self.dismiss(animated: true, completion: nil)
    }

    func enteredPin() -> String?{
        return pinTextField.text
    }
}
