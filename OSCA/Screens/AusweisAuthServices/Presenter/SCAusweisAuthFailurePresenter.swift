//
//  SCAusweisAuthFailurePresenter.swift
//  OSCA
//
//  Created by Bharat Jagtap on 01/03/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
