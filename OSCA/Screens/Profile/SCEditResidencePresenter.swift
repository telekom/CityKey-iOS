/*
Created by Harshada Deshmukh on 15/02/21.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Harshada Deshmukh
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

protocol SCEditResidenceDisplaying: AnyObject, SCDisplaying  {
    func setupNavigationBar(title: String)
    func setupUI(postcode: String)
    
    func postcodeFieldContent() -> String?
    
    
    func showPostcodeMessage(message: String)
    func showPostcodeError(message: String)
    func hidePostcodeError()
    func showPostcodeOK()
    
    func push(viewController: UIViewController)
    func present(viewController: UIViewController)
    func setSubmitButtonState(_ state : SCCustomButtonState)
    func presentOnTop(viewController: UIViewController, completion: (() -> Void)?)
    func dismiss(completion: (() -> Void)?)
    func dismissView(completion: (() -> Void)?)

}

protocol SCEditResidencePresenting: SCPresenting {
    func setDisplay(_ display: SCEditResidenceDisplaying)
    
    func confirmWasPressed()
    func postcodeFieldDidChange()
    func postcodeFieldDidEnd()
    func closeButtonWasPressed()

}

class SCEditResidencePresenter{
    
    weak private var display : SCEditResidenceDisplaying?
    
    private let editResidenceWorker: SCEditResidenceWorking
    private let injector: SCAdjustTrackingInjection & SCToolsShowing
    private var postcode: String
    private var profile: SCModelProfile?
    private var finishViewController : UIViewController?
    private weak var presentedVC: UIViewController?

    init(postcode: String, profile: SCModelProfile, editResidenceWorker: SCEditResidenceWorking, injector: SCAdjustTrackingInjection & SCToolsShowing) {
        
        self.editResidenceWorker = editResidenceWorker
        self.injector = injector
        self.postcode = postcode
        self.profile = profile
                
        self.setupNotifications()
    }
    
    deinit {
    }
    
    private func setupUI() {
        self.display?.setupNavigationBar(title: "p_003_profile_new_postcode_title".localized())
        self.profile = SCUserDefaultsHelper.getProfile()
        self.display?.setupUI(postcode: self.profile?.postalCode ?? "")
    }
    
    private func setupNotifications() {
        
    }
    
    func postcodeFieldDidChange() {
        self.display?.hidePostcodeError()
//        self.updateValidationState()
        self.refreshSubmitButtonState()
    }
    
    func postcodeFieldDidEnd() {
        self.display?.hidePostcodeError()
//        self.updateValidationState()
        self.refreshSubmitButtonState()
    }
    
    private func updateValidationState(){
        let validationResult = SCInputValidation.isInputValid(self.display?.postcodeFieldContent() ?? "", fieldType: .postalCode)
        if !validationResult.isValid {
            self.display?.showPostcodeError(message: "r_001_registration_error_incorrect_postcode".localized())
        }else{
            self.display?.showPostcodeOK()
        }
    }

    private func refreshSubmitButtonState(){
        self.display?.setSubmitButtonState(.disabled)
        if  self.display?.postcodeFieldContent()?.count ?? 0 > 0 {
            self.display?.setSubmitButtonState(.normal)
        }
        else{
            self.display?.hidePostcodeError()
        }
    }

    func validateInputFields() -> Bool{
        var valid = false
        
        // check if the postcode is valid
//        if self.display?.postcodeFieldContent() == self.postcode {
        let validationResult = SCInputValidation.isInputValid(self.display?.postcodeFieldContent() ?? "", fieldType: .postalCode)
        if !validationResult.isValid {
            self.display?.showPostcodeError(message: "r_001_registration_error_incorrect_postcode".localized())
            self.display?.setSubmitButtonState(.disabled)
        }else {
            valid = true
        }
        return valid
    }
    
    private func displayErrorDetail(_ detail : SCWorkerErrorDetails){
                
        let error = detail.errorCode ?? ""
        switch error {
        case "postalCode.validation.error":
            self.display?.showPostcodeError(message: detail.message)
        case "user.postal.code.invalid":
            self.display?.showPostcodeError(message: detail.message)
        default:
            self.display?.showErrorDialog(with: detail.message, retryHandler : nil, showCancelButton: false, additionalButtonTitle: nil, additionButtonHandler: nil)
            break
        }
        
    }
    
    private func submitNewPostcode(_ postcode: String) {
        
        if  validateInputFields() {
            
            self.display?.setSubmitButtonState(.progress)
            
            self.editResidenceWorker.changeResidence("", postcode: postcode, completion: { (error) in
                
                self.display?.setSubmitButtonState(.normal)

                guard error == nil else {
                    switch error! {
                    case .fetchFailed(let errorDetail):
                        self.display?.setSubmitButtonState(.disabled)
                        self.displayErrorDetail(errorDetail)
                    default:
                        self.display?.showErrorDialog(error!, retryHandler: {self.submitNewPostcode(postcode)})
                    }
                    
                    return
                }
                
                SCUtilities.delay(withTime: 0.0, callback: {
                    self.display?.dismissView(completion: nil)
                })
            })
            
        } else {
            self.display?.setSubmitButtonState(.disabled)
        }
        
    }
    
    private func validatePostalCode(_ postcode: String) {
        
        self.display?.setSubmitButtonState(.progress)
        
        self.editResidenceWorker.validatePostalCode(postcode, completion: { (postalCodeInfo, error)  in
            
            self.display?.setSubmitButtonState(.normal)

            guard error == nil else {
                switch error! {
                case .fetchFailed(let errorDetail):
                    self.display?.setSubmitButtonState(.disabled)
                    self.displayErrorDetail(errorDetail)
                default:
                    self.display?.showErrorDialog(error!, retryHandler: {self.validatePostalCode(postcode)})
                }
                
                return
            }
            
            self.display?.showPostcodeMessage(message: postalCodeInfo?.postalCodeMessage ?? "")
            self.updatePersonalData(postcode, validatePostcodeData: postalCodeInfo!)
            self.submitNewPostcode(postcode)
        })
        
    }
    
    private func updatePersonalData(_ postcode: String, validatePostcodeData: SCHttpResponseValidatePostcode){
        self.profile?.postalCode = postcode
        self.profile?.cityName = validatePostcodeData.cityName
        self.profile?.homeCityId = validatePostcodeData.homeCityId
        SCUserDefaultsHelper.setProfile(profile: self.profile!)

    }
    
}

extension SCEditResidencePresenter: SCPresenting {
    
    func viewDidLoad() {
        debugPrint("SCEditResidencePresenter->viewDidLoad")
        self.setupUI()
        self.display?.setSubmitButtonState(.disabled)
        
    }
    
    func viewWillAppear() {
        debugPrint("SCEditResidencePresenter->viewWillAppear")
    }
    
    func viewDidAppear() {
        
    }
    
    
}

extension SCEditResidencePresenter: SCEditResidencePresenting {
    
    func setDisplay(_ display: SCEditResidenceDisplaying) {
        self.display = display
    }
    
    func confirmWasPressed(){
        //self.injector.trackEvent(eventName: "ClickChangeEmailConfirmBtn")
        if  validateInputFields() {
            if let postcode = self.display?.postcodeFieldContent(){
                self.validatePostalCode(postcode)
            }
        } else {
            self.display?.setSubmitButtonState(.disabled)
        }
    }
    
    func closeButtonWasPressed() {
        self.display?.dismiss(completion: nil)
    }
}
