/*
Created by Bharat Jagtap on 01/03/21.
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

protocol SCAusweisAuthFailurePresenting : SCPresenting {

    func setDisplay(display : SCAusweisAuthFailureViewDisplay)
    func onTryAgain()
}

class SCAusweisAuthFailurePresenter {

    weak var display : SCAusweisAuthFailureViewDisplay?
    var worker : SCAusweisAuthWorking
    var injector : SCAusweisAuthServiceInjecting & SCAdjustTrackingInjection
    var errorMessage : String?
    
    init(worker : SCAusweisAuthWorking, injector : SCAusweisAuthServiceInjecting & SCAdjustTrackingInjection) {
        self.worker = worker
        self.injector = injector
    }
    
    func viewDidLoad() {
        
        /// This is a dirty hack : To Do - need to be though of and improved in future
        /// While user clicks on the restart the workflow , we do get few repeatative messages  from SDK ( mostly AUTH with error I guess or some other error messages ) that triggers the showing of this controller , so with that we loose the state if user has already clicked on restart workflow button
        /// That was cuasing the display of a fresh error screen ( current screen ) and user would feel that the clicking on restart button did not work
        /// so when we restart the workflow we save the error sate inside the worker.state.authFlowError
        /// this state will be reset from  SCAusweisAuthServiceOverViewPresenter in ViewDidLoad
        
        if let lastErrorState = self.worker.state.authWorkflowError {
            
            display?.showErrorMessage(errorMessage: lastErrorState.authErrorMessage, errorDescription: lastErrorState.authErrorDescription)
            display?.setRestartWorkflowInProgress(inProgress: lastErrorState.authReStarted)
       }

    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
    
}

extension SCAusweisAuthFailurePresenter : SCAusweisAuthFailurePresenting {
    
    func setDisplay(display : SCAusweisAuthFailureViewDisplay) {
        self.display = display
    }
    
    func onTryAgain() {
        
        if !SCUtilities.isInternetAvailable() {
            
            self.display?.showNoInternetAvailableDialog(retryHandler: nil, showCancelButton: true, additionalButtonTitle: nil, additionButtonHandler: nil)
            return
        }
                
        var authWorkFlowErrorState = self.worker.state.authWorkflowError
        authWorkFlowErrorState?.authReStarted = true
        self.worker.state.authWorkflowError = authWorkFlowErrorState
        
        display?.setRestartWorkflowInProgress(inProgress: true)
        self.worker.restartWorkflow()
    }
    
}
