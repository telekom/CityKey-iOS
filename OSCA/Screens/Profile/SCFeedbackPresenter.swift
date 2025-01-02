//
//  SCFeedbackPresenter.swift
//  OSCA
//
//  Created by Ayush on 09/09/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
