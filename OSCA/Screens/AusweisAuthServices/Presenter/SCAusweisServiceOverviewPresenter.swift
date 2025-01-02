//
//  SCAusweisServiceOverviewPresenter.swift
//  OSCA
//
//  Created by Bharat Jagtap on 28/02/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

protocol SCAusweisAuthServiceOverviewPresenting : SCPresenting {
    func setDisplay(display: SCAusweisAuthServiceOverviewDisplay)
    func onClickEnterPIN()
    func onMoreInfoClicked()
}

class SCAusweisAuthServiceOverviewPresenter {
    weak var display : SCAusweisAuthServiceOverviewDisplay!
    var worker : SCAusweisAuthWorking
    private let injector: SCAdjustTrackingInjection
    
    init(worker : SCAusweisAuthWorking, injector: SCAdjustTrackingInjection) {
        self.worker = worker
        self.injector = injector
    }

    private func getBulletListFrom(textItems : [String] ) -> String {
        
        var resultString = ""
        for item in textItems {
            resultString.append("› \(item) \n")
        }
        return resultString
    }
}

extension SCAusweisAuthServiceOverviewPresenter : SCAusweisAuthServiceOverviewPresenting {
    
    func setDisplay(display: SCAusweisAuthServiceOverviewDisplay) {
        
        self.display = display
    }
    
    func viewDidLoad() {
        
        /// if the workflow is restared because of some Failure in which user had entered PIN, CAN ior PUK , it would be carried to the new workflow, so when user arrives at any Pin, Can, Puk entry , he would already see the wrong number entered with the error message.
        /// So we clear it at the start of the workflow , do not clear any other things from the state
        /// we also clear the authWorkFlowError state
        self.worker.clearPinCanPukStoredState()
        
        self.display.setProvider(provider: self.worker.state.certificate?.subjectName ?? "" )
        self.display.setProviderDataRequiredInfo(dataRequired: self.getBulletListFrom(textItems: self.worker.state.accessRights?.effective ?? [""]) )
        self.display.setPurposeInfo(purpose: self.worker.state.certificate?.purpose ?? "")
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
    
    func onClickEnterPIN() {
     
        if !SCUtilities.isInternetAvailable() {
            
            self.display.showNoInternetAvailableDialog(retryHandler: nil, showCancelButton: true, additionalButtonTitle: nil, additionButtonHandler: nil)
            return
        }
        
        self.worker.onAcceptCertificate()
        
    }
    
    func onMoreInfoClicked() {
        
        self.worker.onServiceOverviewMoreInfoClicked()
    }
    
}
