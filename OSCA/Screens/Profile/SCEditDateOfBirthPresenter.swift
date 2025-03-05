/*
Created by Bharat Jagtap on 29/04/21.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Bharat Jagtap
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import Foundation
import UIKit

protocol SCEditDateOfBirthDisplaying : AnyObject , SCDisplaying {
    
    func setupNavigationBar(title: String)
    func setupUI(dob: String?)
    
    func dobFieldContent() -> String?
    
    
    func showDobMessage(message: String)
    func showDobError(message: String)
    func hideDobError()
    func showDobOK()
    
    func push(viewController: UIViewController)
    func present(viewController: UIViewController)
    func setSubmitButtonState(_ state : SCCustomButtonState)
    func setClearDOBButtonState(_ state : SCCustomButtonState)
    func presentOnTop(viewController: UIViewController, completion: (() -> Void)?)
    func dismiss(completion: (() -> Void)?)
    func dismissView(completion: (() -> Void)?)
    func popViewController()
}

protocol SCEditDateOfBirthPresenting: SCPresenting {
    func setDisplay(_ display: SCEditDateOfBirthDisplaying)
    
    func confirmWasPressed()
    func dobFieldDidChange()
    func dobFieldDidEnd()
    func closeButtonWasPressed()
    func clearDOBButtonWasPressed()
}

class SCEditDateOfBirthPresenter {
    
    weak private var display : SCEditDateOfBirthDisplaying?
    
    private let editDateOfBirthWorker: SCEditDateOfBirthWorking
    private let injector: SCAdjustTrackingInjection & SCToolsShowing
    private var profile: SCModelProfile?
    private var finishViewController : UIViewController?
    private weak var presentedVC: UIViewController?
    private var flow: DateOfBirth?
    private var completionHandler: ((String?) -> Void)?

    init(profile: SCModelProfile?, editDateOfBirthWorker: SCEditDateOfBirthWorking, injector: SCAdjustTrackingInjection & SCToolsShowing, flow: DateOfBirth? = .editProfile, completionHandler: ((String?) -> Void)?) {
        
        self.profile = profile
        self.editDateOfBirthWorker = editDateOfBirthWorker
        self.injector = injector
        self.flow = flow
        self.completionHandler = completionHandler
    }
    
    deinit {
    }
    
    private func setupUI() {
        
        if let date = self.profile?.birthdate {
            let dateString = birthdayStringFromDate(birthdate: date)
            self.display?.setupUI(dob : dateString)
            self.display?.setupNavigationBar(title: "p_003_change_dob_title".localized())
        } else {
            self.display?.setupUI(dob : nil)
            self.display?.setupNavigationBar(title: "p_003_add_date_of_birth_title".localized())
        }
    }
    
    func dobFieldDidChange() {
        self.display?.hideDobError()
        self.updateValidationState()
        self.refreshSubmitButtonState()
    }
    
    func dobFieldDidEnd() {
        self.display?.hideDobError()
        self.updateValidationState()
        self.refreshSubmitButtonState()
    }
    
    private func updateValidationState(){
        let validationResult = SCInputValidation.isInputValid(self.display?.dobFieldContent() ?? "", fieldType: .birthdate)
        if !validationResult.isValid {
            self.display?.showDobError(message: "error".localized())
        }else{
            self.display?.showDobOK()
        }
    }

    private func refreshSubmitButtonState(){
        self.display?.setSubmitButtonState(.disabled)
        if  self.display?.dobFieldContent()?.count ?? 0 > 0 {
            
            self.display?.setSubmitButtonState(.normal)
        } else {
            
            self.display?.hideDobError()
        }
    }

    func validateInputFields() -> Bool{
        var valid = false
        
        let validationResult = SCInputValidation.isInputValid(self.display?.dobFieldContent() ?? "", fieldType: .birthdate)
        
        if !validationResult.isValid {
            self.display?.showDobError(message: "error".localized())
            self.display?.setSubmitButtonState(.disabled)
        }else {
            valid = true
        }
        return valid
    }
    
    private func displayErrorDetail(_ detail : SCWorkerErrorDetails){
                
        let error = detail.errorCode ?? ""
        switch error {
        case "dateOfBirthvalidation.error":
            self.display?.showDobError(message: detail.message)
        case "user.dob.not.valid":
            self.display?.showDobError(message: detail.message)
        default:
            self.display?.showErrorDialog(with: detail.message, retryHandler : nil, showCancelButton: true, additionalButtonTitle: nil, additionButtonHandler: nil)
            break
        }
        
    }
    
    private func submitNewDateOfBirth(_ dob: String) {
        
        if  validateInputFields() {
            
            self.display?.setSubmitButtonState(.progress)
            
            self.editDateOfBirthWorker.updateDateOfBirth(dob, completion: { (error) in
                
                self.display?.setSubmitButtonState(.normal)

                guard error == nil else {
                    switch error! {
                    case .fetchFailed(let errorDetail):
                        self.display?.setSubmitButtonState(.disabled)
                        self.displayErrorDetail(errorDetail)
                    default:
                        self.display?.showErrorDialog(error!, retryHandler: {
                            
                            self.submitNewDateOfBirth(dob)
                            
                        })
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
    
    private func updateDateOfBirth(_ dob: String ){

        if !validateInputFields() {
            self.display?.setSubmitButtonState(.disabled)
            return
        }
               
        self.display?.setSubmitButtonState(.progress)

        var formattedBirthDate : String = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        if let date = dateFormatter.date(from: dob) {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            formattedBirthDate = dateFormatter.string(from: date)
        }
        
        guard formattedBirthDate.count >  0 else { return }
        
        self.editDateOfBirthWorker.updateDateOfBirth(formattedBirthDate) { (error) in
            
            self.display?.setSubmitButtonState(.normal)
            
            guard error == nil else {
                switch error! {
                case .fetchFailed(let errorDetail):
                    self.display?.setSubmitButtonState(.disabled)
                    self.displayErrorDetail(errorDetail)
                default:
                    self.display?.showErrorDialog(error!, retryHandler: {self.updateDateOfBirth(formattedBirthDate)})
                }
                return
            }
            
            dateFormatter.dateFormat = "dd.MM.yyyy"
            if let date = dateFormatter.date(from: dob) {
                self.profile?.birthdate = date
                SCUserDefaultsHelper.setProfile(profile: self.profile!)
            }
            
            SCUtilities.delay(withTime: 0.0, callback: {
                self.display?.dismissView(completion: nil)
            })

        }
    }
    
    
    private func clearDateOfBirth(){

        self.display?.setSubmitButtonState(.disabled)
        self.display?.setClearDOBButtonState(.progress)
        
        self.editDateOfBirthWorker.clearDateOfBirth(completion: { (error) in
            
            self.display?.setSubmitButtonState(.normal)
            self.display?.setClearDOBButtonState(.normal)

            guard error == nil else {
                switch error! {
                case .fetchFailed(let errorDetail):
                    self.display?.setClearDOBButtonState(.disabled)
                    self.displayErrorDetail(errorDetail)
                default:
                    self.display?.showErrorDialog(error!, retryHandler: { self.clearDateOfBirth() })
                }
                return
            }
            
            self.profile?.birthdate = nil
            SCUserDefaultsHelper.setProfile(profile: self.profile!)
            SCUtilities.delay(withTime: 0.0, callback: {
                self.display?.dismissView(completion: nil)
            })

        })
    }
}

extension SCEditDateOfBirthPresenter: SCEditDateOfBirthPresenting {
   
    func setDisplay(_ display: SCEditDateOfBirthDisplaying) {
        self.display = display
    }
    
    func viewDidLoad() {
        debugPrint("SCEditDateOfBirthPresenter->viewDidLoad")
        self.setupUI()
        self.display?.setSubmitButtonState(.disabled)
    }
    
    func viewWillAppear() {
        debugPrint("SCEditDateOfBirthPresenter->viewWillAppear")
    }
    
    func viewDidAppear() {
        
    }
    
    
}

extension SCEditDateOfBirthPresenter {
    
    
    func confirmWasPressed(){
        //self.injector.trackEvent(eventName: "ClickChangeEmailConfirmBtn")
        if  validateInputFields() {
            if let dob = self.display?.dobFieldContent(), 
                validateInputFields() {
                if let dobFlow = flow, dobFlow == DateOfBirth.registration {
                    completionHandler?(formattedDateOfBirth(dobTxt: dob))
                    self.display?.popViewController()
                } else {
                    self.updateDateOfBirth(dob)
                }
            }
        } else {
            self.display?.setSubmitButtonState(.disabled)
        }
    }
    
    func closeButtonWasPressed() {
        self.display?.dismiss(completion: nil)
    }
    
    func clearDOBButtonWasPressed() {
        clearDateOfBirth()
    }
    
    fileprivate func formattedDateOfBirth(dobTxt: String) -> String {
        let components = dobTxt.split(separator: ".")
        guard components.count == 3 else { return dobTxt }
        let months = getLocalizedMonths()
        let month = (Int(components[1]) ?? 1) - 1
        return "\(components[0]). \(months[month]) \(components[2])"
    }
}
