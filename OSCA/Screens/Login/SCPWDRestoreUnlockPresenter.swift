/*
Created by Michael on 19.06.19.
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

enum SCPWDRestoreUnlockVCType {
    case pwdForgotten
    case pwdLocked
}

protocol SCPWDRestoreUnlockDisplaying: AnyObject, SCDisplaying  {
    func setupNavigationBar(title: String, backTitle: String)
    func setupUI()
    func refreshUI(screenTitle: String, detail : String, iconName : String, btnText: String, defaultEmail : String)
    
    func getValue(for inputField: SCPWDRestoreUnlockInputFields) -> String?
    func getFieldType(for inputField: SCPWDRestoreUnlockInputFields) -> SCTextfieldComponentType
    func hideError(for inputField: SCPWDRestoreUnlockInputFields)
    func showError(for inputField: SCPWDRestoreUnlockInputFields, text: String)
    func showMessagse(for inputField: SCPWDRestoreUnlockInputFields, text: String, color: UIColor)
    func deleteContent(for inputField: SCPWDRestoreUnlockInputFields)
    func updateValidationState(for inputField: SCPWDRestoreUnlockInputFields, state: SCTextfieldValidationState)
    func getValidationState(for inputField: SCPWDRestoreUnlockInputFields) -> SCTextfieldValidationState
    func setEnable(for inputField: SCPWDRestoreUnlockInputFields,enabled : Bool )
    func dismissKeyboard()

    func updatePWDChecker(charCount: Int,  minCharReached : Bool, symbolAvailable : Bool, digitAvailable: Bool)

    func dismissView(animated flag: Bool, completion: (() -> Void)?)
    func overlay(viewController: UIViewController, title: String)
    
    func setRecoverButtonState(_ state : SCCustomButtonState)
    func recoverButtonState() -> SCCustomButtonState
    
}

protocol SCPWDRestoreUnlockPresenting: SCPresenting {
    func setDisplay(_ display: SCPWDRestoreUnlockDisplaying)
    
    func configureField(_ field: SCTextFieldConfigurable?, identifier: String?, type: SCPWDRestoreUnlockInputFields, autocapitalizationType: UITextAutocapitalizationType) -> SCTextFieldConfigurable?
    
    func textFieldComponentDidChange(for inputField: SCPWDRestoreUnlockInputFields)
    func txtFieldEditingDidEnd(value : String, inputField: SCPWDRestoreUnlockInputFields, textFieldType: SCTextfieldComponentType)

    func recoveryWasPressed()
    func cancelWasPressed()
    
}

class SCPWDRestoreUnlockPresenter: NSObject {
    
    weak private var display : SCPWDRestoreUnlockDisplaying?
    
    private let restoreUnlockWorker: SCPWDRestoreUnlockWorking
    private let injector: SCPWDRestoreUnlockInjecting & SCAdjustTrackingInjection
    private var email: String
    private var vcType : SCPWDRestoreUnlockVCType = .pwdForgotten
    private var finishViewController : UIViewController?
    private let completionOnSuccess : ((String, Bool, Bool?, String?) -> Void)?

    init(email: String, screenType: SCPWDRestoreUnlockVCType, restoreUnlockWorker: SCPWDRestoreUnlockWorking, injector: SCPWDRestoreUnlockInjecting & SCAdjustTrackingInjection, completionOnSuccess: ((_ eMail : String, _ emailWasAlreadySentBefore: Bool, _ isError:Bool?, _ errorMessage: String?) -> Void)?) {
        
        self.restoreUnlockWorker = restoreUnlockWorker
        self.injector = injector
        self.email = email
        self.vcType = screenType
        self.completionOnSuccess = completionOnSuccess
        
        super.init()
        
        self.setupNotifications()
    }
    
    deinit {
        SCDataUIEvents.discardNotifications(for: self)
    }
    
    private func setupUI() {
        var detail = ""
        var navigationTitle = ""
        var iconName = ""
        
        self.display?.setupNavigationBar(title: "l_001_login_title".localized(), backTitle: "")
        self.display?.setupUI()
        
        switch vcType {
            
        case .pwdForgotten:
            detail = "f_001_forgot_password_info_click_link".localized()
            navigationTitle = "f_001_forgot_password_btn_reset_password".localized()
            iconName = "icon_reset_password"
            
        case .pwdLocked:
            detail = "f_001_forgot_password_info_locked_account".localized()
            navigationTitle = "l_002_login_locked_account_title".localized()
            iconName = "icon_account_locked"
        }
        
        self.display?.refreshUI(screenTitle: navigationTitle, detail : detail, iconName : iconName, btnText: "f_001_forgot_password_btn_reset_password".localized(), defaultEmail: self.email)
    }
    
    
    private func setupNotifications() {
        
    }
    
    private func startRecover(){
        
        let newPWD1 = self.display?.getValue(for: .pwd1) ?? ""
        let newPWD2 = self.display?.getValue(for: .pwd2) ?? ""
        let email = (self.display?.getValue(for: .email) ?? "").trimmingCharacters(in: .whitespaces)

        let firstPwdResult = SCInputValidation.validateFirstPassword(newPWD1, email: email)
        let secondPwdResult = SCInputValidation.validateSecondPassword(newPWD2, firstPwd: newPWD1)

        var valid = true
        
        // check if passwords are valid
        if firstPwdResult != .strong || secondPwdResult != .pwdsAreMatching{
            valid = false
        }
        
        // all data fields
        let textFields = [SCPWDRestoreUnlockInputFields.email]
    
        for textField in textFields {
            self.display?.hideError(for: textField)
            self.display?.updateValidationState(for: textField, state: .unmarked)

            let validationResult = SCInputValidation.isInputValid(self.display?.getValue(for: textField) ?? "" , fieldType: self.display?.getFieldType(for: textField) ?? .text)
            if validationResult.isValid {
                if (textField == .pwd1 || textField == .pwd1){
                    self.display?.updateValidationState(for: textField, state: .ok)
                }
            } else {
                self.display?.showError(for: textField, text: validationResult.message ?? "Unknown error")
                self.display?.updateValidationState(for: textField, state: .wrong)
                valid = false
            }
        }
        
        if valid{
            self.recoverPWD(eMail: email, pwd: newPWD1)
        }

    }
    
    
    private func recoverPWD(eMail: String, pwd: String){
        
        self.display?.setRecoverButtonState(.progress)
        
        self.display?.dismissKeyboard()

        self.restoreUnlockWorker.recoverPassword(eMail, pwd: pwd, completion: { (successful, error) in
            self.display?.setRecoverButtonState(.normal)
            
            DispatchQueue.main.async {
                self.display?.setRecoverButtonState(.disabled)
                
                guard error == nil else {
                    switch error! {
                    case .fetchFailed(let errorDetail):
                        let errorCode = errorDetail.errorCode ?? ""
                        switch errorCode {
                        case "password.not.valid":
                            self.display?.showError(for: .pwd1, text: errorDetail.message)
                        case "email.no.exist":
                            self.display?.showError(for: .email, text: errorDetail.message)
                        case "email.not.verified":
                            self.recoverFinished(eMail: eMail, emailWasAlreadySentBefore: true, isError: nil, errorMessage: nil)
                        case "resend.too.soon":
                            self.recoverFinished(eMail: eMail, emailWasAlreadySentBefore: true, isError: true, errorMessage: errorDetail.message)
                        default:
                            self.display?.showErrorDialog(error!, retryHandler: {self.recoverPWD(eMail: eMail, pwd: pwd)})
                            break
                        }
                    default:
                        self.display?.showErrorDialog(error!, retryHandler: {self.recoverPWD(eMail: eMail, pwd: pwd)})
                    }
                    return
                }
                
                self.recoverFinished(eMail: eMail, emailWasAlreadySentBefore: false, isError: nil, errorMessage: nil)
                return
            }
        })

    }
    
    private func recoverFinished(eMail : String, emailWasAlreadySentBefore: Bool, isError: Bool?, errorMessage: String?){
        self.display?.updateValidationState(for: .email, state: .ok)
        self.display?.setRecoverButtonState(.disabled)

        SCUtilities.delay(withTime: 2.0, callback: {
            self.completionOnSuccess?(eMail, emailWasAlreadySentBefore, isError, errorMessage)
        })

    }

    func updateRecoverButtonState() {
        self.display?.setRecoverButtonState(.normal)

        let newPWD1 = self.display?.getValue(for: .pwd1) ?? ""
        let newPWD2 = self.display?.getValue(for: .pwd2) ?? ""
        let email = (self.display?.getValue(for: .email) ?? "").trimmingCharacters(in: .whitespaces)

        let firstPwdResult = SCInputValidation.validateFirstPassword(newPWD1, email: email)
        let secondPwdResult = SCInputValidation.validateSecondPassword(newPWD2, firstPwd: newPWD1)

        self.display?.setRecoverButtonState(.normal)
        
        let textFields = [SCPWDRestoreUnlockInputFields.email]
        
        // check all textfields if they are valid
        for textField in textFields {
            if (self.display?.getValue(for: textField) ?? ""  ).isEmpty || self.display?.getValidationState(for: textField) == .wrong{
                self.display?.setRecoverButtonState(.disabled)
            }
        }
        
        // check if passwords are valid
        if firstPwdResult != .strong || secondPwdResult != .pwdsAreMatching{
            self.display?.setRecoverButtonState(.disabled)
        }

    }

}

extension SCPWDRestoreUnlockPresenter: SCPresenting {
    
    func viewDidLoad() {
        debugPrint("SCPWDRestoreUnlockPresenter->viewDidLoad")
        //self.injector.trackEvent(eventName: "OpenForgottenPassword")
        self.setupUI()
        self.display?.setRecoverButtonState(.disabled)
    }
}

extension SCPWDRestoreUnlockPresenter: SCPWDRestoreUnlockPresenting {
    func setDisplay(_ display: SCPWDRestoreUnlockDisplaying) {
        self.display = display
    }
    
    func configureField(_ field: SCTextFieldConfigurable?, identifier: String?, type: SCPWDRestoreUnlockInputFields, autocapitalizationType: UITextAutocapitalizationType) -> SCTextFieldConfigurable?
    {
        guard let textfield = field, let identifier = identifier else {
            return nil
        }
        
        switch identifier {
            
        case "sgtxtfldEmail":
            if type == .email {
                textfield.configure(placeholder: "f_001_forgot_password_hint_email".localized(), fieldType: .email, maxCharCount: 255, autocapitalization: autocapitalizationType)
                return textfield
            }
        case "sgtxtfldPwd1":
            if type == .pwd1 {
                textfield.configure(placeholder: "f_001_forgot_password_change_hint_new_password".localized(), fieldType: .newPassword, maxCharCount: 255, autocapitalization: autocapitalizationType)
                return textfield
            }
        case "sgtxtfldPwd2":
            if type == .pwd2 {
                textfield.configure(placeholder: "f_001_forgot_password_change_hint_repeat_password".localized(), fieldType: .newPassword, maxCharCount: 255, autocapitalization: autocapitalizationType)
                textfield.setEnabled(false)
                return textfield
            }
            
        default:
            return nil
        }
        return nil
    }

    func textFieldComponentDidChange(for inputField: SCPWDRestoreUnlockInputFields) {
        
        // on each keypress check if the password was changed. In this case we will delete the password validation field
        if inputField == .pwd1 {
            self.display?.deleteContent(for: .pwd2)
            self.updateStatusForPasswordFields()
        } else if inputField == .pwd2 {
            self.updateStatusForPasswordFields()
        } else {
            // For all other fields hide error when changing content
            self.display?.hideError(for: inputField)
        }
        
        self.updateRecoverButtonState()
    }
    
    func txtFieldEditingDidEnd(value : String, inputField: SCPWDRestoreUnlockInputFields, textFieldType: SCTextfieldComponentType) {
        // when leaving a field we need to validate it directly
        
        // don't delete validation errors for password fields
        if inputField != .pwd1 &&  inputField != .pwd2 {
            self.display?.hideError(for: inputField)
            self.display?.updateValidationState(for: inputField, state: .unmarked)
        }

        let validationResult = SCInputValidation.isInputValid(value , fieldType: textFieldType)
        if !validationResult.isValid {
            self.display?.showError(for: inputField, text: validationResult.message ?? "Unknown error")
            self.display?.updateValidationState(for: inputField, state: .wrong)
        }
    }

    func updateStatusForPasswordFields(){
        let newPWD1 = self.display?.getValue(for: .pwd1) ?? ""
        let newPWD2 = self.display?.getValue(for: .pwd2) ?? ""
        let email = (self.display?.getValue(for: .email) ?? "").trimmingCharacters(in: .whitespaces)

        let firstPwdResult = SCInputValidation.validateFirstPassword(newPWD1, email: email)
        let secondPwdResult = SCInputValidation.validateSecondPassword(newPWD2, firstPwd: newPWD1)
        
        switch firstPwdResult {
            case .tooWeak:
                self.display?.setEnable(for: .pwd2 ,enabled: false)
                self.display?.showError(for: .pwd1, text: "r_001_registration_error_password_too_weak".localized())
            case .sameAsEMail:
                self.display?.setEnable(for: .pwd2 ,enabled: false)
                self.display?.showError(for: .pwd1, text:"r_001_registration_error_password_email_same".localized())
            case .strong:
                self.display?.setEnable(for: .pwd2 ,enabled: true)
                self.display?.showMessagse(for:  .pwd1, text: "r_001_registration_hint_password_strong".localized(), color: UIColor(named: "CLR_LABEL_TEXT_GREEN")!)
                self.display?.updateValidationState(for: .pwd1, state: .ok)
            case .empty:
                self.display?.setEnable(for: .pwd2 ,enabled: false)
                self.display?.hideError(for: .pwd1)
                self.display?.hideError(for: .pwd2)
        }
        
        switch secondPwdResult {
            case .pwdsAreDifferent:
                if SCInputValidation.isPwdString(newPWD1, startingWith: newPWD2) {
                    self.display?.hideError(for: .pwd2)
                } else {
                 self.display?.showError(for: .pwd2, text:  "r_001_registration_error_password_no_match".localized())
                }
            case .pwdsAreMatching:
                self.display?.showMessagse(for:  .pwd1, text: "r_001_registration_hint_password_strong".localized(), color: UIColor(named: "CLR_LABEL_TEXT_GREEN")!)
                self.display?.hideError(for: .pwd2)
                self.display?.updateValidationState(for: .pwd2, state: .ok)
            case .empty:
                self.display?.hideError(for: .pwd2)
        }
        
        self.display?.updatePWDChecker(charCount: newPWD1.count , minCharReached: SCInputValidation.passwordMinCharReached(pwd: newPWD1), symbolAvailable: SCInputValidation.passwordContainsSymbol(pwd: newPWD1), digitAvailable: SCInputValidation.passwordContainsDigit(pwd: newPWD1))

    }


    func recoveryWasPressed(){
        self.startRecover()
    }
    
    func cancelWasPressed(){
        if vcType == SCPWDRestoreUnlockVCType.pwdLocked {
            SCDataUIEvents.postNotification(for: Notification.Name.userDidSignOut)
        }
        self.display?.dismissView(animated: true, completion: nil)
    }
    
}
