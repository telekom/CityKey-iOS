//
//  SCAusweisAuthEnterPukPresenter.swift
//  OSCA
//
//  Created by Bharat Jagtap on 19/03/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

protocol SCAusweisAuthEnterPukPresenting : SCPresenting {
    func setDisplay(display : SCAusweisAuthEnterPukViewDisplay )
}

class SCAusweisAuthEnterPukPresenter {
    
    weak var display : SCAusweisAuthEnterPukViewDisplay?
    var worker : SCAusweisAuthWorking
    var injector : SCAusweisAuthServiceInjecting
    
    init(worker : SCAusweisAuthWorking, injector : SCAusweisAuthServiceInjecting) {
        self.worker = worker
        self.injector = injector
    }
    
    func viewDidLoad() {
    
        display?.setNumberOfDigitsForPin(digits: 10)
        
        display?.setOnNeedHelpButtonClick {
            self.worker.onEnterPinHelpClicked()
        }
        
        display?.setOnPinHelpButtonClick {

        }
        
        display?.setOnSubmitButtonClick { [weak self] in
                          
            if !SCUtilities.isInternetAvailable() {
                
                self?.display?.showNoInternetAvailableDialog(retryHandler: nil, showCancelButton: true, additionalButtonTitle: nil, additionButtonHandler: nil)
                return
            }
            
            if let puk = self?.display?.pin {
             
                self?.worker.onSubmitPUK(puk: puk)
            }
        }
        
        if let lastPuk = self.worker.state.enterPuk?.pukSubmitted {
         
            let errorMessage = self.worker.state.enterPuk?.pukModel?.error ?? "egov_puk_info_invalid_puk_label".localized()
               
            display?.setHeader2(text: errorMessage, error: true)
            display?.pin = lastPuk
            display?.setIsPinInvalid(isPinInvalid: true)
        }
        
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
    
    func setDisplay(display : SCAusweisAuthEnterPukViewDisplay ) {
        
        self.display = display
    }
    
}

extension SCAusweisAuthEnterPukPresenter : SCAusweisAuthEnterPukPresenting {
    
}
