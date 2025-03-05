/*
Created by Bharat Jagtap on 03/03/21.
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

protocol SCAusweisAuthEnterPinPresenting : SCPresenting {
    func setDisplay(display : SCAusweisAuthEnterPinViewDisplay )
}

class SCAusweisAuthEnterPinPresenter {
    
    weak var display : SCAusweisAuthEnterPinViewDisplay?
    var worker : SCAusweisAuthWorking
    var injector : SCAusweisAuthServiceInjecting
    
    init(worker : SCAusweisAuthWorking, injector : SCAusweisAuthServiceInjecting) {
        self.worker = worker
        self.injector = injector
    }
    
    func viewDidLoad() {
    
        display?.setNumberOfDigitsForPin(digits: 6)
        
        display?.setOnNeedHelpButtonClick {
            SCFileLogger.shared.write("SCAusweisAuthEnterPinPresenter -> setOnNeedHelpButtonClick ", withTag: .ausweis)
            self.worker.onEnterPinHelpClicked()            
        }
        
        display?.setOnPinHelpButtonClick {
            SCFileLogger.shared.write("SCAusweisAuthEnterPinPresenter -> setOnPinHelpButtonClick ", withTag: .ausweis)
            self.worker.onEnterPinHelpClicked()
        }
        
        display?.setOnSubmitButtonClick { [weak self] in
            
            SCFileLogger.shared.write("SCAusweisAuthEnterPinPresenter -> setOnSubmitButtonClick ", withTag: .ausweis)
            if !SCUtilities.isInternetAvailable() {
                
                self?.display?.showNoInternetAvailableDialog(retryHandler: nil, showCancelButton: true, additionalButtonTitle: nil, additionButtonHandler: nil)
                return
            }
            
            if let pin = self?.display?.pin {
                self?.worker.onSubmitPIN(pin: pin)
            }
        }
        
        
        if let submittedPin = worker.state.enterPin?.pinSubmitted , let pinModel = worker.state.enterPin?.pinModel {
            
            SCFileLogger.shared.write("SCAusweisAuthEnterPinPresenter -> viewDidLoad -> pin already submitted and we are retrying to enter valid pin ", withTag: .ausweis)
            
            display?.pin = submittedPin
            
            if pinModel.retryCounter < 3 {

                SCFileLogger.shared.write("SCAusweisAuthEnterPinPresenter -> viewDidLoad -> pinModel.retryCounter < 3", withTag: .ausweis)
                
                var message : String = ""
//                if pinModel.retryCounter == 2 { message = "egov_pin_error_two_retries".localized() }
//                else { message = "egov_pin_error_one_retry".localized() }
                message = pinModel.retryCounter == 2 ? "egov_pin_error_two_retries".localized() : "egov_pin_error_one_retry".localized()
                self.display?.setHeader2(text: message, error: true)
                self.display?.setIsPinInvalid(isPinInvalid: true)
                
            } else {
                
                SCFileLogger.shared.write("SCAusweisAuthEnterPinPresenter -> viewDidLoad -> pinModel.retryCounter > 3", withTag: .ausweis)
                
            }
        }
        
                
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
    
    func setDisplay(display : SCAusweisAuthEnterPinViewDisplay ) {
        
        self.display = display
    }
    
}

extension SCAusweisAuthEnterPinPresenter : SCAusweisAuthEnterPinPresenting {
    
}
