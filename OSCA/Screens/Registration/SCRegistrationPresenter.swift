/*
Created by Michael on 04.06.19.
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

enum SCRegistrationInputFields {
    case email
    case pwd1
    case pwd2
    case birthdate
    case postalCode
}

enum SCHandledRegistrationValidationError: String, CaseIterable {
    case password = "password"
    case email = "email"
    case birthday = "birthday"
    case monheimpasscardid = "monheimpasscardid"
    case emailpassword = "emailpassword"
}

enum SCHandledRegistrationError: String, CaseIterable {
    case postalValidationError = "postalCode.validation.error"
    case birthdateValidationError = "dateOfBirth.validation.error"
    case passwordValidationError = "pwd.validation.error"
    case emailValidationError = "email.validation.error"
    case userTooYoungError = "user.too.young"
    case userDateNotValidError = "user.dob.not.valid"
    case emailNotValidrror = "user.email.not.valid"
    case emailExistsError = "user.email.exists"
    case emailNotVerifiedError = "user.email.not.verified"
    case emailResendTooSoon = "resend.too.soon"
}

protocol SCRegistrationDisplaying: AnyObject, SCDisplaying {
    
    func setupNavigationBar(title: String, backTitle: String)
    func setupUI(title: String)
    func setDisallowedCharacterForPassword(_ disallowedChars: String)
    func setDisallowedCharacterForEMail(_ disallowedChars: String)
    func dismissView(animated flag: Bool, completion: (() -> Void)?)
    func dismissKeyboard()
    func setSubmitButtonState(_ state : SCCustomButtonState)
    
    func getValue(for inputField: SCRegistrationInputFields) -> String?
    func getFieldType(for inputField: SCRegistrationInputFields) -> SCTextfieldComponentType
    func hideError(for inputField: SCRegistrationInputFields)
    func showError(for inputField: SCRegistrationInputFields, text: String)
    func showMessagse(for inputField: SCRegistrationInputFields, text: String, color: UIColor)
    func scrollContent(to inputField: SCRegistrationInputFields)
    func deleteContent(for inputField: SCRegistrationInputFields)
    func updateValidationState(for inputField: SCRegistrationInputFields, state: SCTextfieldValidationState)
    func getValidationState(for inputField: SCRegistrationInputFields) -> SCTextfieldValidationState
    func setEnable(for inputField: SCRegistrationInputFields,enabled : Bool )
    func updatePrivacyValidationState(_ accepted : Bool, showErrorInfoWhenNotAccepted: Bool)
    func updatePrivacyCheckbox(accepted: Bool)
    
    func updatePWDChecker(charCount: Int,  minCharReached : Bool, symbolAvailable : Bool, digitAvailable: Bool)
    
    func overlay(viewController: UIViewController)
    func push(viewController: UIViewController)
    func present(viewController: UIViewController)
    func updateDobText(dob: String?)
}

protocol SCRegistrationPresenting: SCPresenting {
    func setDisplay(_ display: SCRegistrationDisplaying)
    
    func configureField(_ field: SCTextFieldConfigurable?, identifier: String?, type: SCRegistrationInputFields, autocapitalizationType: UITextAutocapitalizationType) -> SCTextFieldConfigurable?
    
    func textFieldComponentDidChange(for inputField: SCRegistrationInputFields)
    func txtFieldEditingDidEnd(value : String, inputField: SCRegistrationInputFields, textFieldType: SCTextfieldComponentType)
    func submitWasPressed()
    func privacyWasPressed()
    func closeWasPressed()
    func dataPrivacyLinkWasPressed()
    func textFieldDateOfBirthTapped()
}

class SCRegistrationPresenter {
    weak private var display : SCRegistrationDisplaying?
    
    private let registrationWorker: SCRegistrationWorking
    private let injector: SCRegistrationInjecting & SCLegalInfoInjecting & SCAdjustTrackingInjection
    
    var privacyAccepted: Bool = false
    
    private let appContentSharedWorker: SCAppContentSharedWorking
    private var sentRegistration: SCModelRegistration?
    private let completionOnSuccess : ((String, Bool?, String?) -> Void)?
    
    init(registrationWorker: SCRegistrationWorking, appContentSharedWorker: SCAppContentSharedWorking, injector: SCRegistrationInjecting & SCLegalInfoInjecting & SCAdjustTrackingInjection, completionOnSuccess: ((_ eMail : String, _ isErrorPresent: Bool?, _ errorMessage: String?) -> Void)?) {
        
        self.registrationWorker = registrationWorker
        self.appContentSharedWorker = appContentSharedWorker
        self.injector = injector
        self.completionOnSuccess = completionOnSuccess
    }
    
    deinit {
        
    }
    
    private func setupUI() {
        self.display?.setupNavigationBar(title: "r_001_registration_title".localized(), backTitle: "")
        self.display?.setupUI(title: "r_001_registration_btn_register".localized())
        self.display?.setDisallowedCharacterForPassword(" ")
        self.display?.setDisallowedCharacterForEMail(" ")
    }
    
    
    func textFieldComponentDidChange(for inputField: SCRegistrationInputFields) {
        
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
        
        // SMARTC-17491 iOS: Registration: No error message when invalid retype password.
        if inputField == .birthdate || inputField == .postalCode{
            let secondPwdResult = SCInputValidation.validateSecondPassword(self.display?.getValue(for: .pwd1) ?? "", firstPwd: self.display?.getValue(for: .pwd2) ?? "")
            if secondPwdResult != .pwdsAreMatching{
                self.display?.showError(for: .pwd2, text:  "r_001_registration_error_password_no_match".localized())
            }
            else{
                self.display?.hideError(for: .pwd2)
            }
        }
        
        self.updateRegistrationButtonState()
    }
    
    func txtFieldEditingDidEnd(value : String, inputField: SCRegistrationInputFields, textFieldType: SCTextfieldComponentType) {
        // when leaving a field we need to validate it directly
        
        // don't delete validation errors for password fields
        if inputField != .pwd1 &&  inputField != .pwd2 {
            self.display?.hideError(for: inputField)
            self.display?.updateValidationState(for: inputField, state: .unmarked)
        }

        /// SMARTC-16267 Birthdate is an optinoal field now
        /// did not modify SCInputValidation.isInputValid for this since I am not sure of this validation is used / will be used from some place
        if textFieldType == .birthdate { return }
        
        
        let validationResult = SCInputValidation.isInputValid(value , fieldType: textFieldType)
        if !validationResult.isValid {
            self.display?.showError(for: inputField, text: validationResult.message ?? "Unknown error")
            self.display?.updateValidationState(for: inputField, state: .wrong)
        }
        
        self.updateRegistrationButtonState()
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

    func updateRegistrationButtonState() {
        self.display?.setSubmitButtonState(.normal)

        let newPWD1 = self.display?.getValue(for: .pwd1) ?? ""
        let newPWD2 = self.display?.getValue(for: .pwd2) ?? ""
        let email = (self.display?.getValue(for: .email) ?? "").trimmingCharacters(in: .whitespaces)

        let firstPwdResult = SCInputValidation.validateFirstPassword(newPWD1, email: email)
        let secondPwdResult = SCInputValidation.validateSecondPassword(newPWD2, firstPwd: newPWD1)

        self.display?.setSubmitButtonState(.normal)
        
        let textFields = [SCRegistrationInputFields.email, SCRegistrationInputFields.postalCode]
        
        // check all textfields if they are valid
        for textField in textFields {
            if (self.display?.getValue(for: textField) ?? ""  ).isEmpty || self.display?.getValidationState(for: textField) == .wrong{
                self.display?.setSubmitButtonState(.disabled)
            }
        }
        
        // check if passwords are valid
        if firstPwdResult != .strong || secondPwdResult != .pwdsAreMatching{
            self.display?.setSubmitButtonState(.disabled)
        }

    }

    func isErrorHandled(_ detail : SCWorkerErrorDetails) -> Bool {
        let errorCode = detail.errorCode ?? ""
        guard SCHandledRegistrationError(rawValue: errorCode) != nil else { return false }
        return true
    }
    
    private func displayErrorDetail(_ detail : SCWorkerErrorDetails){
        let error = detail.errorCode ?? ""
        switch error {
        case "postalCode.validation.error":
            self.display?.showError(for: .postalCode, text: detail.message)
            self.display?.scrollContent(to: .postalCode)
        case "dateOfBirth.validation.error":
            self.display?.showError(for: .birthdate, text: detail.message)
            self.display?.scrollContent(to: .birthdate)
        case "pwd.validation.error":
            self.display?.showError(for: .pwd1, text: detail.message)
            self.display?.scrollContent(to: .pwd1)
        case "email.validation.error":
            self.display?.showError(for: .email, text: detail.message)
            self.display?.scrollContent(to: .email)
        case "user.too.young":
            self.display?.showError(for: .birthdate, text: detail.message)
            self.display?.scrollContent(to: .birthdate)
        case "user.dob.not.valid":
            self.display?.showError(for: .birthdate, text: detail.message)
            self.display?.scrollContent(to: .birthdate)
        case "user.email.not.valid":
            self.display?.showError(for: .email, text: detail.message)
            self.display?.scrollContent(to: .email)
        case "user.email.exists":
            self.display?.showError(for: .email, text: detail.message)
            self.display?.scrollContent(to: .email)
        case "user.email.not.verified":
            self.display?.showError(for: .email, text: detail.message)
            self.display?.scrollContent(to: .email)
        case "resend.too.soon":
            let eMail = (self.display?.getValue(for: .email) ?? "").trimmingCharacters(in: .whitespaces)
            self.display?.updateValidationState(for: .email, state: .ok)
            self.display?.setSubmitButtonState(.disabled)

            SCUtilities.delay(withTime: 2.0, callback: {
                self.completionOnSuccess?(eMail, true, detail.message)
            })
        default:
            self.display?.showErrorDialog(with: detail.message, retryHandler : nil, showCancelButton: false, additionalButtonTitle: nil, additionButtonHandler: nil)
            break
        }
    }
    
    
    private func startRegistration(){
        
        let newPWD1 = self.display?.getValue(for: .pwd1) ?? ""
        let newPWD2 = self.display?.getValue(for: .pwd2) ?? ""
        let email = (self.display?.getValue(for: .email) ?? "").trimmingCharacters(in: .whitespaces)
        let birthdate = self.display!.getValue(for: .birthdate)
        let postalCode = self.display!.getValue(for: .postalCode)!

        let firstPwdResult = SCInputValidation.validateFirstPassword(newPWD1, email: email)
        let secondPwdResult = SCInputValidation.validateSecondPassword(newPWD2, firstPwd: newPWD1)

        var valid = true
        
        // check if passwords are valid
        if firstPwdResult != .strong || secondPwdResult != .pwdsAreMatching{
            valid = false
        }
        
        // all data fields
        let textFields = [SCRegistrationInputFields.email, SCRegistrationInputFields.postalCode]
    
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
        
        // check privcy
        if !self.privacyAccepted {
            valid = false
        }

        self.display?.updatePrivacyValidationState(self.privacyAccepted, showErrorInfoWhenNotAccepted: true)

        if !self.privacyAccepted {
            valid = false
        }
        
        guard valid == true else { return }
        
        var formattedBirthdate : String? = nil
        
        if let birthdate = birthdate {
            // change birthday format
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            if let date = dateFormatter.date(from:birthdate) {
                dateFormatter.dateFormat = "yyyy-MM-dd"
                formattedBirthdate = dateFormatter.string(from: date)
            }
        }
        
        self.register(eMail: email, pwd: newPWD1, birthDate: formattedBirthdate, postalCode: postalCode)
//
//        if let date = dateFormatter.date(from:birthdate) {
//            // reformat the birthdate date to a backend complient one
//            if valid {
//                self.register(eMail: email, pwd: newPWD1, birthDate: formattedBirthdate, postalCode: postalCode)
//            }
//        } else {
//            self.display?.updateValidationState(for: .birthdate, state: .unmarked)
//            self.display?.deleteContent(for: .birthdate)
//            self.updateRegistrationButtonState()
//        }

    }
    
    
    private func register(eMail: String, pwd: String, birthDate: String?,
                  postalCode: String){
        
        self.display?.setSubmitButtonState(.progress)
        
        self.display?.dismissKeyboard()

        let userRegistrationData = SCModelRegistration(eMail: eMail, pwd: pwd, language: SCUtilities.preferredContentLanguage(), birthdate: birthDate, postalCode: postalCode, privacyAccepted: true)
        
        SCUserDefaultsHelper.setRegistration(registration: userRegistrationData)
        
        // call backend
        self.registrationWorker.register(registration: userRegistrationData) { (successfult, postalCodeInfo, error) in
            
            DispatchQueue.main.async {
                self.display?.setSubmitButtonState(.disabled)
                
                guard error == nil else {
                    switch error! {
                    case .fetchFailed(let errorDetail):
                        if self.isErrorHandled(errorDetail) {
                            self.displayErrorDetail(errorDetail)
                            self.updateRegistrationButtonState()
                        } else {
                            self.display?.showErrorDialog(error!, retryHandler: {self.register(eMail: eMail, pwd: pwd, birthDate: birthDate, postalCode: postalCode)})
                        }
                    default:
                        self.display?.showErrorDialog(error!, retryHandler: {self.register(eMail: eMail, pwd: pwd, birthDate: birthDate, postalCode: postalCode)})
                    }
                    return
                }
                
                self.sentRegistration = userRegistrationData
                self.registrationWasSuccessful(eMail: eMail, postalCodeInfo: postalCodeInfo ?? "")
                return
            }
        }
    }
    
    private func registrationWasSuccessful(eMail : String, postalCodeInfo: String){
        self.display?.updateValidationState(for: .email, state: .ok)
        self.display?.updateValidationState(for: .birthdate, state: .ok)
        self.display?.updateValidationState(for: .postalCode, state: .ok)
        self.display?.showMessagse(for: .postalCode, text: postalCodeInfo, color: UIColor(named: "CLR_LABEL_TEXT_GREEN")!)
        self.display?.setSubmitButtonState(.disabled)

        SCUtilities.delay(withTime: 2.0, callback: {
            self.completionOnSuccess?(eMail, nil, nil)
        })

    }
}

extension SCRegistrationPresenter: SCPresenting {
    
    func viewDidLoad() {
        self.setupUI()
        self.display?.setSubmitButtonState(.disabled)
        //self.injector.trackEvent(eventName: "OpenRegistration")
    }
}

extension SCRegistrationPresenter: SCRegistrationPresenting {

    func setDisplay(_ display: SCRegistrationDisplaying) {
        self.display = display
    }
    
    func configureField(_ field: SCTextFieldConfigurable?, identifier: String?, type: SCRegistrationInputFields, autocapitalizationType: UITextAutocapitalizationType) -> SCTextFieldConfigurable?
    {
        guard let textfield = field, let identifier = identifier else {
            return nil
        }
        
        switch identifier {
            
        case "sgtxtfldEmail":
            if type == .email {
                textfield.configure(placeholder: "r_001_registration_hint_email".localized(), fieldType: .email, maxCharCount: 255, autocapitalization: autocapitalizationType)
                return textfield
            }
        case "sgtxtfldPwd1":
            if type == .pwd1 {
                textfield.configure(placeholder: "r_001_registration_hint_password".localized(), fieldType: .newPassword, maxCharCount: 255, autocapitalization: autocapitalizationType)
                return textfield
            }
        case "sgtxtfldPwd2":
            if type == .pwd2 {
                textfield.configure(placeholder: "r_001_registration_hint_password_repeat".localized(), fieldType: .newPassword, maxCharCount: 255, autocapitalization: autocapitalizationType)
                textfield.setEnabled(false)
                return textfield
            }
        case "sgtxtfldBirthdate":
            if type == .birthdate {
                textfield.configure(placeholder: "r_001_registration_hint_birthday".localized(), fieldType: .birthdate, maxCharCount: 10, autocapitalization: autocapitalizationType)
                return textfield
            }
        case "sgtxtfldPostalCode":
            if type == .postalCode {
                textfield.configure(placeholder: "r_001_registration_hint_postcode".localized(), fieldType: .postalCode, maxCharCount: 5, autocapitalization: autocapitalizationType)
                return textfield
            }
            
        default:
            return nil
        }
        return nil
    }
    
    func submitWasPressed() {
        //self.injector.trackEvent(eventName: "ClickRegistrationConfirmedBtn")
        self.startRegistration()
    }
    
    func privacyWasPressed() {
        
        self.privacyAccepted = !self.privacyAccepted
        
        self.display?.updatePrivacyCheckbox(accepted: self.privacyAccepted)
        self.display?.updatePrivacyValidationState(self.privacyAccepted, showErrorInfoWhenNotAccepted: false)

    }
    
    func closeWasPressed() {
        self.display?.dismissView(animated: true, completion:nil)
    }
    
    func dataPrivacyLinkWasPressed() {
//        let dataPrivacyVC = self.injector.getDataPrivacyController(presentationType: .dataPrivacy,insideNavCtrl: false)
        let dataPrivacyVC = self.injector.getDataPrivacyController(preventSwipeToDismiss: false, shouldPushSettingsController: true)

        self.display?.push(viewController: dataPrivacyVC)
    }

    func textFieldDateOfBirthTapped() {
        self.display?.push(viewController: self.injector.getProfileEditDateOfBirthViewController(in: .registration, completionHandler: { dob in
            self.display?.updateDobText(dob: dob)
        }))
    }
}
