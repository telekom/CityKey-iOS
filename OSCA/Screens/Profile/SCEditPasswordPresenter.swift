/*
Created by Michael on 21.06.19.
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

protocol SCEditPasswordDisplaying: AnyObject, SCDisplaying  {
    func setupNavigationBar(title: String)
    func setupUI()
    func oldPWDContent() -> String?
    func newPWD1Content() -> String?
    func newPWD2Content() -> String?
    
    func showOldPWDError(message: String)
    func showOldPWDOK()
    func hideOldPWDError()
    func showNewPWD1Error(message: String)
    func showNewPWD1OK(message: String?)
    func hideNewPWD1Error()
    func showNewPWD2Error(message: String)
    func showNewPWD2OK()
    func hideNewPWD2Error()
    func deleteContentNewPWD2()
    
    func enableNewPWD2(_ enabled : Bool)
    func enableAllFields(_ enabled : Bool)
    func refreshPWDCheck(charCount: Int,  minCharReached : Bool, symbolAvailable : Bool, digitAvailable: Bool, showRedLineAnyway : Bool)
    
    func push(viewController: UIViewController)
    func setSubmitButtonState(_ state : SCCustomButtonState)
    func dismiss(completion: (() -> Void)?)
    func presentOnTop(viewController: UIViewController, completion: (() -> Void)?)
}

protocol SCEditPasswordPresenting: SCPresenting {
    func setDisplay(_ display: SCEditPasswordDisplaying)
    func didChangeTextField()
    func confirmWasPressed()
    func forgotPWDWasPressed()
    func liveCheckTextFields(checkPassFld2: Bool)
    func isNewPWD1StartsWithNewPWD2() -> Bool
    func validateNewPasswords()
    func closeButtonWasPressed()
}

class SCEditPasswordPresenter: NSObject {
    
    weak private var display : SCEditPasswordDisplaying?
    
    private let editPasswordWorker: SCEditPasswordWorking
    private let injector: SCEditPasswordInjecting & SCAdjustTrackingInjection & SCRegistrationInjecting & SCToolsShowing
    private var email: String
    private var finishViewController : UIViewController?
    private weak var presentedVC: UIViewController?
    
    init(email: String, editPasswordWorker: SCEditPasswordWorking,
         injector: SCEditPasswordInjecting & SCAdjustTrackingInjection & SCRegistrationInjecting & SCToolsShowing) {
        
        self.editPasswordWorker = editPasswordWorker
        self.injector = injector
        self.email = email
        
        super.init()
        
        self.setupNotifications()
    }
    
    deinit {
    }
    
    
    private func setupUI() {
        self.display?.setupNavigationBar(title: "p_001_profile_label_account_settings".localized())
        self.display?.setupUI()
    }
    
    private func setupNotifications() {
        
    }
    
    
    
    func passwordMinCharReached() -> Bool{
        let newPWD1 = self.display?.newPWD1Content() ?? ""
        return SCPasswordCheck.passwordMinCharReached(pwd: newPWD1)
    }
    
    func passwordContainsSymbol() -> Bool{
        let newPWD1 = self.display?.newPWD1Content() ?? ""
        return SCPasswordCheck.passwordContainsSymbol(pwd: newPWD1)
    }
    
    func passwordContainsDigit() -> Bool {
        let newPWD1 = self.display?.newPWD1Content() ?? ""
        return SCPasswordCheck.passwordContainsDigit(pwd: newPWD1)
    }
    
    private func displayErrorDetail(_ detail : SCWorkerErrorDetails) -> Bool{
        
        let error = detail.errorCode ?? ""
        var errorDisplayed = true
        
        switch error {
            
            /*
        case "form.validation.error":
            
            guard let errorObject = detail.errorObjects else {
                return false
            }
            
            for valError in errorObject{
                switch valError.field.lowercased() {
                case  "emailpassword":
                    self.display?.showNewPWD1Error(message: detail.message)
                    self.display?.showOldPWDError(message: detail.message)
                case  "newpassword":
                    self.display?.showNewPWD1Error(message: detail.message)
                    self.display?.showNewPWD2Error(message: detail.message)
                default:
                    errorDisplayed = false
                }
            }*/
            
        case "oldPwd.incorrect":
            self.display?.showOldPWDError(message: detail.message)
        case "newPwd.not.valid":
            self.display?.showNewPWD1Error(message: detail.message)
        case "newPwd.email.equal":
            self.display?.showNewPWD1Error(message: detail.message)
            self.display?.showNewPWD2Error(message: detail.message)
            
        default:
            errorDisplayed = false
            
        }
        return errorDisplayed
    }
    
    private func submitNewPassword(currentPassword: String, newPassword: String) {
        
        self.display?.setSubmitButtonState(.progress)
        // self.display?.enableAllFields(false)    // will be enabled in next sprinits
        self.editPasswordWorker.changePassword(currentPassword: currentPassword, newPassword: newPassword, completion: { (error) in
            
            self.display?.setSubmitButtonState(.disabled)
            // self.display?.enableAllFields(true)    // will be enabled in next sprinits
            guard error == nil else {
                switch error! {
                case .fetchFailed(let errorDetail):
                    if !self.displayErrorDetail(errorDetail){
                        self.display?.showErrorDialog(SCWorkerError.technicalError, retryHandler: {self.submitNewPassword(currentPassword: currentPassword, newPassword: newPassword)})
                    }
                default:
                    self.display?.showErrorDialog(error!, retryHandler: {self.submitNewPassword(currentPassword: currentPassword, newPassword: newPassword)})
                }
                return
            }
            
            // show completion view
            
            self.display?.push(viewController: self.injector.getEditPasswordFinishedViewController(email: self.email))
            
        })
    }
    
}

extension SCEditPasswordPresenter: SCPresenting {
    
    func viewDidLoad() {
        debugPrint("SCEditPasswordPresenter->viewDidLoad")
        self.setupUI()
    }
    
    func viewWillAppear() {
        debugPrint("SCEditPasswordPresenter->viewWillAppear")
    }
    
    func viewDidAppear() {
        
    }
    
    
}

extension SCEditPasswordPresenter: SCEditPasswordPresenting {
    
    func setDisplay(_ display: SCEditPasswordDisplaying) {
        self.display = display
    }
    
    func didChangeTextField(){
        // check on each keypress if the password validation textfield should be enabled or disabled
        if self.newPassword1Strong(){
            self.display?.enableNewPWD2(true)
        } else {
            self.display?.enableNewPWD2(false)
        }
    }
    
    func liveCheckTextFields(checkPassFld2: Bool){
        _ = self.display?.oldPWDContent() ?? ""
        let newPWD1 = self.display?.newPWD1Content() ?? ""
        let newPWD2 = self.display?.newPWD2Content() ?? ""
        
        if newPasswordValid()
        {
            self.display?.setSubmitButtonState(.normal)
        } else {
            self.display?.setSubmitButtonState(.disabled)
        }
        
        self.display?.refreshPWDCheck(charCount: newPWD1.count , minCharReached: self.passwordMinCharReached(), symbolAvailable: self.passwordContainsSymbol(), digitAvailable: self.passwordContainsDigit(), showRedLineAnyway : false)
        
        if  !newPWD1.isEmpty{
            
            // if there is something wrong with the password then we should
            if !self.newPassword1Strong() { //(!self.passwordContainsSymbol() || !self.passwordMinCharReached() || !self.passwordContainsDigit()){
                self.display?.showNewPWD1Error(message: "p_005_profile_password_change_error_too_weak".localized())
            } else if !newPassword1SameAsEmail(){
                self.display?.enableNewPWD2(false)
                self.display?.showNewPWD1Error(message: "r_001_registration_error_password_email_same".localized())
            }
            else {
                self.display?.showNewPWD1OK(message: "p_005_profile_password_change_info_strength_strong".localized())
            }
            
        }
        
        if checkPassFld2 && !isNewPWD1StartsWithNewPWD2() && !newPWD2.isEmpty {
            self.display?.showNewPWD2Error(message: "p_005_profile_password_change_error_no_match".localized())
        }else if checkPassFld2{
            self.display?.hideNewPWD2Error()
            if newPWD1==newPWD2 {
                self.display?.showNewPWD2OK()
            }
        }
        if newPWD2.isEmpty{
            self.display?.hideNewPWD2Error()
        }
    }
    
    func isNewPWD1StartsWithNewPWD2() -> Bool{
        let newPWD1 = self.display?.newPWD1Content() ?? ""
        let newPWD2 = self.display?.newPWD2Content() ?? ""
        let startPartOfnewPWD1OfLengthOfNewPWD2=newPWD1.prefix(newPWD2.count)
        if (startPartOfnewPWD1OfLengthOfNewPWD2==newPWD2) {
            return true
        } else {
            return false
        }
    }
    
    func validateNewPasswords() {
        if self.display?.newPWD2Content() == "" {
            self.display?.hideNewPWD2Error()
        } else if self.password1EqualsPassword2() {
            self.display?.hideNewPWD2Error()
            self.display?.showNewPWD2OK()
        } else {
            self.display?.showNewPWD2Error(message: "p_005_profile_password_change_error_no_match".localized())
        }
    }
    
    func password1EqualsPassword2() -> Bool {
        let firstNewPassword = self.display?.newPWD1Content() ?? ""
        let secondNewPassword = self.display?.newPWD2Content() ?? ""
        return firstNewPassword.elementsEqual(secondNewPassword)
    }
    
    func confirmWasPressed(){
        //self.injector.trackEvent(eventName: "ClickChangePasswordConfirmBtn")
        let oldPWD = self.display?.oldPWDContent()
        let newPWD = self.display?.newPWD1Content()
        self.submitNewPassword(currentPassword: oldPWD!, newPassword: newPWD!)
    }
    
    
    func forgotPWDWasPressed(){
        //self.injector.trackEvent(eventName: "ClickForgotPasswordBtn")
        let navCtrl = UINavigationController()
        navCtrl.viewControllers = [self.injector.getPWDForgottenViewController(email: self.email, completionOnSuccess: { [weak self] (email, emailWasAlreadySentBefore, isError, errorMessage) in
            navCtrl.dismiss(animated: true, completion: {
                let confirmViewController = self?.injector.getRegistrationConfirmEMailVC(registeredEmail:email,
                                                                                         shouldHideTopImage: false,
                                                                                         presentationType:emailWasAlreadySentBefore ? .confirmMailSentBeforeRegistration : .confirmMailForPWDReset,
                                                                                         isError: isError,
                                                                                         errorMessage: errorMessage,
                                                                                         completionOnSuccess: {
                    self?.presentedVC?.dismiss(animated: true, completion:{})
                    self?.presentedVC = nil
                    SCAuth.shared.logout(logoutReason: .updateSuccessful,completion:  {
                        self?.display?.dismiss(completion: nil)
                        self?.injector.showProfile()
                    })
                })
                self?.presentedVC = confirmViewController
                if let viewController = confirmViewController {
                    self?.display?.presentOnTop(viewController: viewController, completion: nil)
                }
            })
        })]
        
        SCUtilities.topViewController().present(navCtrl, animated: true, completion: nil)
    }
    
    private func newPasswordValid() -> Bool {
        let oldPWD = self.display?.oldPWDContent() ?? ""
        let newPWD1 = self.display?.newPWD1Content() ?? ""
        let newPWD2 = self.display?.newPWD2Content() ?? ""
        return self.newPassword1Strong() && newPWD1==newPWD2 && !oldPWD.isEmpty //&& newPWD1 != oldPWD && newPWD1 != self.email
    }
    
    private func newPassword1Strong() -> Bool {
        return self.passwordMinCharReached() && self.passwordContainsSymbol() && self.passwordContainsDigit()
    }
    
    private func newPassword1SameAsEmail() -> Bool {
        let newPWD1 = self.display?.newPWD1Content() ?? ""
        return newPWD1 != self.email
    }
    
    func closeButtonWasPressed() {
        self.display?.dismiss(completion: nil)
    }
}

