/*
Created by Michael on 29.03.19.
Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

class SCEditPasswordVC: UIViewController, SCTextfieldComponentDelegate {
    
    public var presenter: SCEditPasswordPresenting!
    
    private let keyboardOffsetSpace : CGFloat = 35.0
    var keyboardHeight : CGFloat = 0.0
    
    @IBOutlet weak var contentScrollview: UIScrollView!
    @IBOutlet weak var submitBtn: SCCustomButton!
    @IBOutlet weak var pwdForgottenBtn: UIButton!
    @IBOutlet weak var closeBtn: UIBarButtonItem!

    private var txtfldOldPwd : SCTextfieldComponent?
    private var txtfldPwd1 : SCTextfieldComponent?
    private var txtfldPwd2 : SCTextfieldComponent?
    private var pwdCheckViewController : SCRegistrationPWDCheckVC?
    private var activeComponent: SCTextfieldComponent?
    
    @IBOutlet weak var pwdCheckVCHeightConstraint: NSLayoutConstraint!
    
    var pwdCheckVCOpenedHeight: CGFloat = 0.0
    var finishViewController : SCEditPasswordFinishedVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        self.shouldNavBarTransparent = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification , object: nil)
        
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
        self.handleDynamicTypeChange()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDynamicTypeChange), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshNavigationBarStyle()
    }

    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.closeBtn.accessibilityIdentifier = "btn_close"
        self.submitBtn.accessibilityIdentifier = "btn_submit"
        self.pwdForgottenBtn.accessibilityIdentifier = "btn_pwd_forgotten"
        self.txtfldOldPwd?.accessibilityIdentifier = "tf_old_pwd"
        self.txtfldPwd1?.accessibilityIdentifier = "tf_new_pwd1"
        self.txtfldPwd2?.accessibilityIdentifier = "tf_new_pwd2"
        self.activeComponent?.accessibilityIdentifier = "tf_component"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }
    
    private func setupAccessibility(){
        self.closeBtn.accessibilityTraits = .button
        self.closeBtn.accessibilityLabel = "accessibility_btn_close".localized()
        self.closeBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }
    
    @objc private func handleDynamicTypeChange() {
        // Dynamic font
        // Setup Dynamic font for Pwd1
        self.txtfldPwd1?.textField.adjustsFontForContentSizeCategory = true
        self.txtfldPwd1?.textField.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 20, maxSize: 25)
        self.txtfldPwd1?.placeholderLabel.adjustsFontForContentSizeCategory = true
        self.txtfldPwd1?.placeholderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 15, maxSize: 25)
        self.txtfldPwd1?.errorLabel.adjustsFontForContentSizeCategory = true
        self.txtfldPwd1?.errorLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        
        // Setup Dynamic font for Pwd2
        self.txtfldPwd2?.textField.adjustsFontForContentSizeCategory = true
        self.txtfldPwd2?.textField.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 20, maxSize: 25)
        self.txtfldPwd2?.placeholderLabel.adjustsFontForContentSizeCategory = true
        self.txtfldPwd2?.placeholderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 15, maxSize: 25)
        self.txtfldPwd2?.errorLabel.adjustsFontForContentSizeCategory = true
        self.txtfldPwd2?.errorLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        
        // Setup Dynamic font for OldPwd
        self.txtfldOldPwd?.textField.adjustsFontForContentSizeCategory = true
        self.txtfldOldPwd?.textField.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 20, maxSize: 23)
        self.txtfldOldPwd?.placeholderLabel.adjustsFontForContentSizeCategory = true
        self.txtfldOldPwd?.placeholderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 15, maxSize: 23)
        self.txtfldOldPwd?.errorLabel.adjustsFontForContentSizeCategory = true
        self.txtfldOldPwd?.errorLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        
        self.pwdForgottenBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        self.pwdForgottenBtn.titleLabel?.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: 20)
        
        self.pwdCheckViewController?.pwdCheckTopLabel.adjustsFontForContentSizeCategory = true
        self.pwdCheckViewController?.pwdCheckTopLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: 15)
        self.pwdCheckViewController?.pwdCheckDetailLabel.adjustsFontForContentSizeCategory = true
        self.pwdCheckViewController?.pwdCheckDetailLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: 15)
        
        self.submitBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        self.submitBtn.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 18, maxSize: 28)
    }

    deinit {
        SCDataUIEvents.discardNotifications(for: self)
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
        
        if self.activeComponent != nil {
            self.scrollComponentToVisibleArea(component: self.activeComponent!)
        }
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        self.contentScrollview.contentInset.bottom = 0.0
    }
    
    
    /**
     *
     * Method to scroll to a component
     */
    
    func scrollComponentToVisibleArea(component: SCTextfieldComponent) {
        var navBarHeight : CGFloat = 0.0
        var aRect : CGRect = self.contentScrollview.bounds
        
        if let navigationController = self.navigationController {
            navBarHeight = navigationController.navigationBar.frame.size.height + navigationController.navigationBar.frame.origin.y
        }
        
        aRect.size.height -= self.keyboardHeight
        aRect.size.height += navBarHeight
        let fieldPoint = CGPoint(x: 0.0 , y: component.textfieldFrame().origin.y + component.textfieldFrame().size.height)
        if !(aRect.contains(fieldPoint))
        {
            self.contentScrollview.setContentOffset(CGPoint(x:0, y:component.textfieldFrame().origin.y - aRect.size.height + keyboardOffsetSpace + component.textfieldFrame().size.height  ), animated: true)
            
        }
    }
    
    
    /**
     *
     * Method to get referenced of the embedded viewController
     *
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.destination {
            
        case let textfield as SCTextfieldComponent:
            textfield.delegate = self
            switch segue.identifier {
            case "sgtxtfldOldPwd":
                self.txtfldOldPwd = textfield
                self.txtfldOldPwd?.configure(placeholder: "p_005_profile_password_change_hint_cur_password".localized(), fieldType: .password, maxCharCount: 255, autocapitalization: .none)
            case "sgtxtfldPwd1":
                self.txtfldPwd1 = textfield
                self.txtfldPwd1?.configure(placeholder: "p_005_profile_password_change_hint_new_password".localized(), fieldType: .newPassword, maxCharCount: 255, autocapitalization: .none)
                
            case "sgtxtfldPwd2":
                self.txtfldPwd2 = textfield
                self.txtfldPwd2?.configure(placeholder: "p_005_profile_password_change_hint_repeat_password".localized(), fieldType: .newPassword, maxCharCount: 255, autocapitalization: .none)
                self.txtfldPwd2?.setEnabled(false)
                
            default:
                break
            }
            
        case let pwdVC as SCRegistrationPWDCheckVC:
            self.pwdCheckViewController = pwdVC
            //get the  height of the view and store it
            self.pwdCheckVCOpenedHeight = self.pwdCheckVCHeightConstraint.constant
            // then set it to 0 to hide the view
            self.pwdCheckVCHeightConstraint.constant = 0.0
        default:
            break
        }
        
        self.setupAccessibilityIDs()

    }
    
    
    func textFieldComponentShouldReturn(component: SCTextfieldComponent) -> Bool {
        component.resignResponder()
        
        if (component == self.txtfldOldPwd){
            if let nextComponent = self.txtfldPwd1 {
                self.scrollComponentToVisibleArea(component: nextComponent)
                nextComponent.becomeResponder()
            }
        }
        if (component == self.txtfldPwd1){
            if let nextComponent = self.txtfldPwd2 {
                self.scrollComponentToVisibleArea(component: nextComponent)
                nextComponent.becomeResponder()
            }
        }
        return true
    }
    
    func textFieldComponentEditingBegin(component: SCTextfieldComponent) {
        
        
        
        self.activeComponent = component
        self.scrollComponentToVisibleArea(component:component)
        
        // we show the password check controller when entering the password field
        if component == self.txtfldPwd1 {
            UIView.animate(withDuration: 0.5, delay: 0.0,
                           options: [.curveEaseInOut], animations: {
                            self.pwdCheckVCHeightConstraint.constant = self.pwdCheckVCOpenedHeight
                            self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    
    func textFieldComponentEditingEnd(component: SCTextfieldComponent) {
        
        if component == self.txtfldPwd1 {
            UIView.animate(withDuration: 0.5, delay: 0.0,
                           options: [.curveEaseInOut], animations: {
                            self.pwdCheckVCHeightConstraint.constant = 0.0
                            self.view.layoutIfNeeded()
            }, completion: nil)
        } else if component == self.txtfldPwd2 {
            self.presenter.validateNewPasswords()
        }
        
    }
    
    func textFieldComponentDidChange(component: SCTextfieldComponent) {
        
        self.presenter.didChangeTextField()
        
        // on each keypress check if the password was changed. In this case we will delete the password validation field
        if component == self.txtfldPwd1 {
            self.deleteContentNewPWD2()
            
        }
        if component == self.txtfldPwd2 {
            self.presenter.liveCheckTextFields(checkPassFld2: true)
        } else {
            self.presenter.liveCheckTextFields(checkPassFld2: false)
        }
        
        // when chaneging a field (execpt passwordfields) then we reset previus error messages
        if component != self.txtfldPwd1 && component != self.txtfldPwd2 {
            component.hideError()
            component.validationState = .unmarked
        }
        
    }
    
    
    @IBAction func submitBtnWasPressed(_ sender: Any) {
        self.activeComponent?.resignResponder()
        self.presenter.confirmWasPressed()
    }
    
    @IBAction func pwdForgottenBtnWasPressed(_ sender: Any) {
        self.activeComponent?.resignResponder()
        self.presenter.forgotPWDWasPressed()
    }
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        self.presenter.closeButtonWasPressed()
    }
}

extension SCEditPasswordVC: SCEditPasswordDisplaying {
    func setupNavigationBar(title: String){
        self.navigationItem.title = "p_005_profile_password_change_title".localized()
        self.navigationItem.backBarButtonItem?.title = ""
        
    }
    
    func setupUI(){
        self.pwdForgottenBtn.setTitle("p_005_profile_password_change_btn_forgot_password".localized(), for: .normal)
        self.pwdForgottenBtn.titleLabel?.adaptFontSize()
        
        self.submitBtn.customizeBlueStyle()
        self.submitBtn.titleLabel?.adaptFontSize()
        self.submitBtn.setTitle("p_005_profile_password_change_btn_save".localized(), for: .normal)
        
        self.txtfldPwd1?.disallowedCharacters = " "
        self.txtfldPwd2?.disallowedCharacters = " "
        self.txtfldOldPwd?.disallowedCharacters = " "
        self.setSubmitButtonState(.disabled)
    }
    
    func setSubmitButtonState(_ state : SCCustomButtonState){
        self.submitBtn.btnState = state
    }
    
    func push(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func oldPWDContent() -> String? {
        return self.txtfldOldPwd?.text
    }
    
    func newPWD1Content() -> String? {
        return self.txtfldPwd1?.text
    }
    
    func newPWD2Content() -> String? {
        return self.txtfldPwd2?.text
    }
    
    func showOldPWDError(message: String){
        self.txtfldOldPwd?.showError(message: message)
        self.txtfldOldPwd?.validationState = .wrong
    }
    
    func showOldPWDOK() {
        self.txtfldOldPwd?.validationState = .ok
    }
    
    func hideOldPWDError(){
        self.txtfldOldPwd?.hideError()
        self.txtfldOldPwd?.validationState = .unmarked
    }
    
    func showNewPWD1Error(message: String){
        self.txtfldPwd1?.showError(message: message)
        self.txtfldPwd1?.validationState = .wrong
    }
    
    func showNewPWD1OK(message: String?) {
        if message?.count ?? 0 > 0 {
            self.txtfldPwd1?.show(message: message!, color: UIColor(named: "CLR_LABEL_TEXT_GREEN")!)
        }
        self.txtfldPwd1?.validationState = .ok
    }
    
    func hideNewPWD1Error(){
        self.txtfldPwd1?.hideError()
        self.txtfldPwd1?.validationState = .unmarked
    }
    
    func showNewPWD2Error(message: String){
        self.txtfldPwd2?.showError(message: message)
        self.txtfldPwd2?.validationState = .wrong
    }
    
    func showNewPWD2OK() {
        self.txtfldPwd2?.validationState = .ok
    }
    
    func hideNewPWD2Error(){
        self.txtfldPwd2?.hideError()
        self.txtfldPwd2?.validationState = .unmarked
    }
    func deleteContentNewPWD2(){
        self.txtfldPwd2?.deleteContent()
    }
    func enableNewPWD2(_ enabled : Bool) {
        self.txtfldPwd2?.setEnabled(enabled)
    }
    func enableAllFields(_ enabled : Bool) {
        self.txtfldOldPwd?.setEnabled(enabled)
        self.txtfldPwd1?.setEnabled(enabled)
        self.txtfldPwd2?.setEnabled(enabled)
    }
    
    func refreshPWDCheck(charCount: Int,  minCharReached : Bool, symbolAvailable : Bool, digitAvailable: Bool,  showRedLineAnyway : Bool = false) {
        self.pwdCheckViewController?.refreshWith(charCount: charCount, minCharReached: minCharReached, symbolAvailable: symbolAvailable, digitAvailable: digitAvailable, showRedLineAnyway: showRedLineAnyway)
    }
    
    func dismiss(completion: (() -> Void)?) {
        self.dismiss(animated: true, completion: completion)
    }
    
    func presentOnTop(viewController: UIViewController, completion: (() -> Void)? = nil) {
        SCUtilities.topViewController().present(viewController, animated: true, completion: completion)
    }
}

