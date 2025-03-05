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

protocol SCEditEMailDisplaying: AnyObject, SCDisplaying  {
    func setupNavigationBar(title: String)
    func setupUI(email: String)
    
    func eMailFieldContent() -> String?
    
    func showEMailError(message: String)
    func hideEMailError()
    func showEMailOK()
    
    func push(viewController: UIViewController)
    func present(viewController: UIViewController)
    func setSubmitButtonState(_ state : SCCustomButtonState)
    func presentOnTop(viewController: UIViewController, completion: (() -> Void)?)
    func dismiss(completion: (() -> Void)?)

}

protocol SCEditEMailPresenting: SCPresenting {
    func setDisplay(_ display: SCEditEMailDisplaying)
    
    func confirmWasPressed()
    func emailFieldDidChange()
    func emailFieldDidEnd()
    func forgotPWDWasPressed()
    func closeButtonWasPressed()

}

class SCEditEMailPresenter: NSObject {
    
    weak private var display : SCEditEMailDisplaying?
    
    private let editEMailWorker: SCEditEMailWorking
    private let authProvider: SCLogoutAuthProviding
    private let injector: SCEditEMailInjecting & SCAdjustTrackingInjection & SCRegistrationInjecting
    private var email: String
    private var finishViewController : UIViewController?
    private weak var presentedVC: UIViewController?

    init(email: String, editEMailWorker: SCEditEMailWorking, authProvider: SCLogoutAuthProviding, injector: SCEditEMailInjecting & SCAdjustTrackingInjection & SCRegistrationInjecting) {
        
        self.editEMailWorker = editEMailWorker
        self.authProvider = authProvider
        self.injector = injector
        self.email = email
        
        super.init()
        
        self.setupNotifications()
    }
    
    deinit {
    }
    
    private func setupUI() {
        self.display?.setupNavigationBar(title: "p_001_profile_label_account_settings".localized())
        self.display?.setupUI(email: self.email)
    }
    
    private func setupNotifications() {
        
    }
    
    func emailFieldDidChange() {
        self.display?.hideEMailError()
        self.updateValidationState()
//        self.refreshSubmitButtonState()
    }
    
    func emailFieldDidEnd() {
        self.display?.hideEMailError()
        self.updateValidationState()
//        self.refreshSubmitButtonState()
    }
    
    private func updateValidationState(){
        self.display?.setSubmitButtonState(.disabled)
        if  self.display?.eMailFieldContent()?.count ?? 0 > 0 {
            let validationResult = SCInputValidation.isInputValid(self.display?.eMailFieldContent() ?? "", fieldType: .email)
            if !validationResult.isValid {
                self.display?.showEMailError(message: "r_001_registration_error_incorrect_email".localized())
                self.display?.setSubmitButtonState(.disabled)
            }else{
                self.display?.showEMailOK()
                self.display?.setSubmitButtonState(.normal)
            }
        }
        else{
            self.display?.hideEMailError()
        }
    }

    private func refreshSubmitButtonState(){
        self.display?.setSubmitButtonState(.disabled)
        if  self.display?.eMailFieldContent()?.count ?? 0 > 0 {
            self.display?.setSubmitButtonState(.normal)
        }
        else{
            self.display?.hideEMailError()
        }
    }

    func validateInputFields() -> Bool{
        var valid = false
        
        // check if the eMail is valid
        let validationResult = SCInputValidation.isInputValid(self.display?.eMailFieldContent() ?? "", fieldType: .email)
        if !validationResult.isValid {
            self.display?.showEMailError(message: "r_001_registration_error_incorrect_email".localized())
            self.display?.setSubmitButtonState(.disabled)
        }else{
            self.display?.showEMailOK()
            valid = true
        }
        return valid
    }
    
    private func displayErrorDetail(_ detail : SCWorkerErrorDetails){
        
        let error = detail.errorCode ?? ""
        
        switch error {
        default:
            self.display?.showEMailError(message: detail.message)
        }
    }

    private func confirmEMail(isErrorPresent: Bool?, errorMessage: String?){
        let confirmViewController =  self.injector.getRegistrationConfirmEMailVC(registeredEmail:self.display?.eMailFieldContent() ?? "", shouldHideTopImage: true, presentationType: .confirmMailForEditEmail, isError: isErrorPresent, errorMessage: errorMessage, completionOnSuccess: {
            self.presentedVC?.dismiss(animated: true, completion:{})
            self.presentedVC = nil
            self.authProvider.logout(logoutReason: .updateSuccessful,completion:  {
                self.display?.dismiss(completion: nil)
            })
        })
        self.presentedVC = confirmViewController
        self.display?.presentOnTop(viewController: confirmViewController, completion: nil)
        
    }
    
    private func submitNewEMail(_ email: String) {
        
        self.display?.setSubmitButtonState(.progress)
        
        self.editEMailWorker.changeEMail(email, completion: { (error) in
            
            self.display?.setSubmitButtonState(.normal)

            guard error == nil else {
                switch error! {
                case .fetchFailed(let errorDetail):
                    self.display?.setSubmitButtonState(.disabled)
                    self.displayErrorDetail(errorDetail)
                default:
                    self.display?.showErrorDialog(error!, retryHandler: {self.submitNewEMail(email)})
                }
                
                return
            }
            
            self.confirmEMail(isErrorPresent: nil, errorMessage: nil)
        })
        
    }
    
}

extension SCEditEMailPresenter: SCPresenting {
    
    func viewDidLoad() {
        debugPrint("SCEditEMailPresenter->viewDidLoad")
        self.setupUI()
        self.display?.setSubmitButtonState(.disabled)
        
    }
    
    func viewWillAppear() {
        debugPrint("SCEditEMailPresenter->viewWillAppear")
    }
    
    func viewDidAppear() {
        
    }
    
    
}

extension SCEditEMailPresenter: SCEditEMailPresenting {
    
    func setDisplay(_ display: SCEditEMailDisplaying) {
        self.display = display
    }
    
    func confirmWasPressed(){
        //self.injector.trackEvent(eventName: "ClickChangeEmailConfirmBtn")
        if let email = self.display?.eMailFieldContent(){
            self.submitNewEMail(email)
        }
    }
    
    func forgotPWDWasPressed(){
        //self.injector.trackEvent(eventName: "ClickForgotPasswordBtn")
        let navCtrl = UINavigationController()
        navCtrl.viewControllers = [self.injector.getPWDForgottenViewController(email: self.email, completionOnSuccess: nil)]
        SCUtilities.topViewController().present(navCtrl, animated: true, completion: nil)
    }
    
    func closeButtonWasPressed() {
        self.display?.dismiss(completion: nil)
    }
}
