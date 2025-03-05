/*
Created by Ayush on 09/09/21.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Ayush
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

protocol SCFeedbackDisplaying: AnyObject, SCDisplaying  {
    
    func dismiss(completion: (() -> Void)?)
    func push(viewController: UIViewController)
    func setSendButtonState(_ state : SCCustomButtonState)
    func getAnswerForWhatDidYouLike() -> String?
    func getAnswerForWhatCanWeDoBetter() -> String?
    func showAlert(error: SCWorkerError)
    func updateEmail(id: String)
    func getContactInformation() -> String?
    func showError(for inputField: SCRegistrationInputFields, text: String)
    func updateValidationState(for inputField: SCRegistrationInputFields, state: SCTextfieldValidationState)
    func hideError(for inputField: SCRegistrationInputFields)
    func updateSendButtonState()
    
}

protocol SCFeedbackPresenting: SCPresenting {
    func sendButtonPressed()
    func setDisplay(_ display: SCFeedbackDisplaying)
    func configureField(_ field: SCTextFieldConfigurable?, identifier: String?, type: SCRegistrationInputFields, autocapitalizationType: UITextAutocapitalizationType) -> SCTextFieldConfigurable?
    func txtFieldEditingDidEnd(value : String, inputField: SCRegistrationInputFields, textFieldType: SCTextfieldComponentType)
    func textFieldComponentDidChange(for inputField: SCRegistrationInputFields)
    func contactMeViaEmailTapped(isContactViaEmailEnabled: Bool, email: String?)
}

class SCFeedbackPresenter: NSObject {
    
    weak private var display : SCFeedbackDisplaying?
    
    private let feedbackWorker: SCFeedbackWorking
    private let cityContentSharedWorker: SCCityContentSharedWorking
    private let injector: SCToolsInjecting & SCAdjustTrackingInjection
    private let userContentSharedWorker: SCUserContentSharedWorking
    let auth: SCAuthStateProviding
    
    init(injector: SCToolsInjecting & SCAdjustTrackingInjection, feedbackWorker: SCFeedbackWorking, cityContentSharedWorker: SCCityContentSharedWorking, userContentSharedWorker: SCUserContentSharedWorking, auth: SCAuthStateProviding = SCAuth.shared) {
        self.injector = injector
        self.feedbackWorker = feedbackWorker
        self.cityContentSharedWorker = cityContentSharedWorker
        self.userContentSharedWorker = userContentSharedWorker
        self.auth = auth
    }
    
    private func presentFeedbackConfirmationVC() {
        let feedbackConfirmationVC = self.injector.getFeedbackConfirmationViewController()
        self.display?.push(viewController: feedbackConfirmationVC)
    }
}

extension SCFeedbackPresenter: SCFeedbackPresenting {

    func sendButtonPressed() {
        self.injector.trackEvent(eventName: AnalyticsKeys.EventName.sendFeedback)
        self.display?.setSendButtonState(.progress)
        let feedbackModel = FeedbackRequestModel(cityID: "\(cityContentSharedWorker.getCityID())",
                                            currentCityName: kSelectedCityName,
                                            aboutApp: display?.getAnswerForWhatDidYouLike(),
                                            improvementOnApp: display?.getAnswerForWhatCanWeDoBetter(),
                                            email: display?.getContactInformation())
        feedbackWorker.sendfeedback(feedback: feedbackModel) { [weak self] error in
            self?.display?.setSendButtonState(.normal)
            if error != nil {
                self?.display?.showAlert(error: error!)
            } else {
                self?.presentFeedbackConfirmationVC()
            }
        }
        
    }

    
    func setDisplay(_ display: SCFeedbackDisplaying) {
        self.display = display
    }
    
    func viewDidLoad() {
        updateEmailAddress()
        self.display?.setSendButtonState(.disabled)
    }
    
    private func updateEmailAddress() {
        let userData = userContentSharedWorker.getUserData()
        guard let emailAddress = userData?.profile.email,
              auth.isUserLoggedIn() else {
            return
        }
        display?.updateEmail(id: emailAddress)
    }

    func configureField(_ field: SCTextFieldConfigurable?, identifier: String?, type: SCRegistrationInputFields, autocapitalizationType: UITextAutocapitalizationType) -> SCTextFieldConfigurable?
    {
        guard let textfield = field, let identifier = identifier else {
            return nil
        }
        
        switch identifier {
            
        case "sgtxtfldEmail":
            if type == .email {
                textfield.configure(placeholder: "r_001_registration_hint_email".localized(),
                                    fieldType: .email, maxCharCount: 255, autocapitalization: autocapitalizationType)
                return textfield
            }
        default:
            return nil
        }
        return nil
    }
    
    func txtFieldEditingDidEnd(value : String, inputField: SCRegistrationInputFields, textFieldType: SCTextfieldComponentType) {
        // when leaving a field we need to validate it directly
        self.display?.hideError(for: inputField)
        self.display?.updateValidationState(for: inputField, state: .unmarked)
        let validationResult = SCInputValidation.isInputValid(value , fieldType: textFieldType)
        if !validationResult.isValid {
            self.display?.showError(for: inputField, text: validationResult.message ?? "Unknown error")
            self.display?.updateValidationState(for: inputField, state: .wrong)
        }
        self.updateSendButtonState()
    }
    
    func textFieldComponentDidChange(for inputField: SCRegistrationInputFields) {
        self.display?.hideError(for: inputField)
        self.updateSendButtonState()
    }
    
    func updateSendButtonState() {
        display?.updateSendButtonState()
    }
    
    func contactMeViaEmailTapped(isContactViaEmailEnabled: Bool, email: String?) {
        guard let email = email,
              !email.isEmpty else {
            display?.hideError(for: .email)
            return
        }
        let validationResult = SCInputValidation.validateEmail(email)
        if (isContactViaEmailEnabled && validationResult.isValid) ||
            (isContactViaEmailEnabled == false) {
            display?.hideError(for: .email)
        } else {
            display?.showError(for: .email, text: validationResult.message ?? "")
        }
    }
}
