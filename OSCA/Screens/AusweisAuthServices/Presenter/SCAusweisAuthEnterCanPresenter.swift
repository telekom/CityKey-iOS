//
//  SCAusweisAuthEnterCanPresenter.swift
//  OSCA
//
//  Created by Bharat Jagtap on 18/03/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

protocol SCAusweisAuthEnterCanPresenting : SCPresenting {
    func setDisplay(display : SCAusweisAuthEnterCanViewDisplay )
}

class SCAusweisAuthEnterCanPresenter {
    
    weak var display : SCAusweisAuthEnterCanViewDisplay?
    var worker : SCAusweisAuthWorking
    var injector : SCAusweisAuthServiceInjecting
    
    init(worker : SCAusweisAuthWorking, injector : SCAusweisAuthServiceInjecting) {
        self.worker = worker
        self.injector = injector
    }
    
    func viewDidLoad() {
    
        display?.setNumberOfDigitsForPin(digits: 6)
        
        display?.setOnNeedHelpButtonClick {
            self.worker.onEnterPinHelpClicked()
        }
        
        // PIN Help button is not visible in case of CAN Entry
        display?.setOnPinHelpButtonClick {
            
        }
        
        display?.setOnSubmitButtonClick { [weak self] in
                                    
            if !SCUtilities.isInternetAvailable() {
                
                self?.display?.showNoInternetAvailableDialog(retryHandler: nil, showCancelButton: true, additionalButtonTitle: nil, additionButtonHandler: nil)
                return
            }
            
            if let can = self?.display?.pin {
                self?.worker.onSubmitCAN(can: can)
            }
        }
        
        
         if let lastCan = self.worker.state.enterCan?.canSubmitted {
         
            let errorMessage = self.worker.state.enterCan?.canModel?.error ?? "egov_can_info_invalid_can_label".localized()
                display?.setHeader2(text: errorMessage, error: true)
                display?.pin = lastCan
                display?.setIsPinInvalid(isPinInvalid: true)
            
        }
    
        
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
    
    func setDisplay(display : SCAusweisAuthEnterCanViewDisplay ) {
        
        self.display = display
    }
    
}

extension SCAusweisAuthEnterCanPresenter : SCAusweisAuthEnterCanPresenting {
    
}
