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

enum SCRegistrationConfirmEMailType {
    case confirmMailForRegistration
    case confirmMailForPWDReset
    case confirmMailSentBeforeRegistration
    case confirmMailForEditEmail

}


protocol SCRegistrationConfirmEMailDisplaying: AnyObject, SCDisplaying {
    
    var registeredEmail: String { get set }
    
    func displayResendFinished(message : String, textColor : UIColor)
    func enteredPin() -> String?
    func clearPinField()
    func displayPinError(message : String)
    func hidePinError()
    func disableConfirmBtn(disable: Bool)
    func showKeyboard()
    func hideKeyboard()

    func overlay(viewController: UIViewController)
    func push(viewController: UIViewController)
    func present(viewController: UIViewController)
    func dismiss()
    func setupUIWithTitleText(titleText: String, topText: String, detailText: String, topImageSymbol: UIImage)
    func hideTopImage()
    func hideConfirmButton()

}

protocol SCRegistrationConfirmEMailPresenting: SCPresenting {
    func setDisplay(_ display: SCRegistrationConfirmEMailDisplaying)

    func resendWasPressed()
    func confirmWasPressed()
    func cancelWasPressed()
}

class SCRegistrationConfirmEMailPresenter {
    weak private var display : SCRegistrationConfirmEMailDisplaying?
    
    private let registrationConfirmWorker: SCRegistrationConfirmEMailWorking
    private let injector: SCRegistrationInjecting & SCAdjustTrackingInjection
    private let registeredEmail: String
    private let completionOnSuccess : (() -> Void)?
    private var finishViewController : UIViewController?
    private let shouldHideTopImage : Bool
    private let isErrorPresent: Bool?
    private let errorMessage: String?
    private let presentationType : SCRegistrationConfirmEMailType

    private var titleText : String?

    init(registeredEmail: String, shouldHideTopImage: Bool,isError:Bool?, errorMessage: String?, presentationType: SCRegistrationConfirmEMailType , registrationConfirmWorker: SCRegistrationConfirmEMailWorking, injector: SCRegistrationInjecting & SCAdjustTrackingInjection, completionOnSuccess: (() -> Void)?) {
        
        self.registeredEmail = registeredEmail
        self.registrationConfirmWorker = registrationConfirmWorker
        self.injector = injector
        self.completionOnSuccess = completionOnSuccess
        self.shouldHideTopImage = shouldHideTopImage
        self.presentationType = presentationType
        self.isErrorPresent = isError
        self.errorMessage = errorMessage
    }
    
    deinit {
        
    }
    
    private func setupUI() {
        if self.shouldHideTopImage {
            self.hideTopImage()
        }
        
        if let isError = isErrorPresent, isError, let message = errorMessage {
            self.display?.displayResendFinished(message: message, textColor: UIColor(named: "CLR_LABEL_TEXT_RED")!)
        }
        
        switch presentationType {
        case .confirmMailSentBeforeRegistration:
            self.display?.setupUIWithTitleText(titleText: "r_004_registration_confirmation_title".localized(), topText: "l_004_login_confirm_email_info_check_inbox".localized().replacingOccurrences(of: "%s", with: registeredEmail), detailText:"r_004_registration_confirmation_info_enter_pin".localized(), topImageSymbol: UIImage(named: "icon_confirm_email")!)
        case .confirmMailForRegistration:
            self.display?.setupUIWithTitleText(titleText: "r_004_registration_confirmation_title".localized(), topText: "r_004_registration_confirmation_info_sent_mail".localized().replacingOccurrences(of: "%s", with: registeredEmail), detailText:"r_004_registration_confirmation_info_enter_pin".localized(), topImageSymbol: UIImage(named: "icon_confirm_email")!)
        case .confirmMailForPWDReset:
            self.display?.setupUIWithTitleText(titleText: "f_001_forgot_password_btn_reset_password".localized(), topText: "r_004_registration_confirmation_info_sent_mail".localized().replacingOccurrences(of: "%s", with: registeredEmail), detailText:"f_002_forgot_pwd_confirmation_info_enter_pin".localized(), topImageSymbol: UIImage(named: "icon_reset_password")!)
        case .confirmMailForEditEmail:
            self.display?.setupUIWithTitleText(titleText: "p_004_profile_email_changed_title".localized(), topText: "r_004_registration_confirmation_info_sent_mail".localized().replacingOccurrences(of: "%s", with: registeredEmail), detailText:"r_004_registration_confirmation_info_enter_pin".localized(), topImageSymbol: UIImage(named: "icon_confirm_email")!)
            self.display?.hideConfirmButton()
        }
    }
 
    private func hideTopImage(){
        self.display?.hideTopImage()
    }
    

    func resendEmail(_ email : String) {
        
        var actionName = ""
        switch presentationType {
        case .confirmMailForPWDReset:
            actionName = "PUT_ResendVerificationPINPasswordReset"
        case .confirmMailSentBeforeRegistration, .confirmMailForRegistration:
            actionName = "PUT_ResendVerificationPIN"
        case .confirmMailForEditEmail:
            actionName = "PUT_ResendVerificationPIN"
        }

        self.registrationConfirmWorker.resendEmail(email, actionName: actionName) { (successful, error) in

            self.display?.clearPinField()

            guard error == nil else {
                switch error {
                case .fetchFailed(let errorDetail):
                    self.display?.displayResendFinished(message: errorDetail.message, textColor: UIColor(named: "CLR_LABEL_TEXT_RED")!)
                default:
                    self.display?.showErrorDialog(error!, retryHandler: {self.resendEmail(email)})
                }
                return
            }
            
            self.display?.displayResendFinished(message: "r_004_registration_confirmation_info_sent_link".localized(), textColor: UIColor(named: "CLR_LABEL_TEXT_GREEN")!)
        }
    }

    func sendPin(_ pin : String, email : String) {
        var actionName = ""
        switch presentationType {
        case .confirmMailForPWDReset:
            actionName = "POST_ValidatePINPasswordReset"
        case .confirmMailSentBeforeRegistration, .confirmMailForRegistration:
            actionName = "POST_ValidatePIN"
        case .confirmMailForEditEmail:
            actionName = "POST_ValidatePIN"
        }

        self.registrationConfirmWorker.validatePin(email, actionName: actionName, pin: pin) { (successful, error) in
            
            self.display?.disableConfirmBtn(disable: true)
            
            guard error == nil else {
                self.display?.showKeyboard()

                switch error {
                case .fetchFailed(let errorDetail):
                    self.display?.displayPinError(message: errorDetail.message)
                default:
                    self.display?.showErrorDialog(error!, retryHandler: {self.sendPin(pin, email: email)})
                }

                return
            }
            
            self.display?.hideKeyboard()
            
            self.finishViewController = self.injector.getRegistrationConfirmEMailFinishedVC(shouldHideTopImage: self.shouldHideTopImage, presentationType: self.presentationType, completionOnSuccess: self.completionOnSuccess)
            
            self.display?.overlay(viewController: self.finishViewController!)
        }
    }

}

extension SCRegistrationConfirmEMailPresenter: SCPresenting {
    
    func viewDidLoad() {
        self.display?.registeredEmail = registeredEmail
        //self.injector.trackEvent(eventName: "OpenRegistrationConfirmation")
        self.setupUI()
    }
    
    func viewWillAppear() {
    }
    
    func viewDidAppear() {
        
    }
    
    
}

extension SCRegistrationConfirmEMailPresenter: SCRegistrationConfirmEMailPresenting {
    
    func setDisplay(_ display: SCRegistrationConfirmEMailDisplaying) {
        self.display = display
    }
    
    func resendWasPressed() {
        self.resendEmail(self.registeredEmail)
    }

    func confirmWasPressed() {
        self.sendPin(self.display?.enteredPin() ?? "", email: self.registeredEmail)
    }

    func cancelWasPressed() {
        // when success screen is shown the we call the completion on success
        if self.finishViewController != nil {
            completionOnSuccess?()
        } else {
            // otherwise only dismiss the screen
            self.display?.dismiss()
        }
        self.finishViewController = nil
    }

}
