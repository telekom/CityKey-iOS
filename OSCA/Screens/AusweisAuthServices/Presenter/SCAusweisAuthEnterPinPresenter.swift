//
//  SCAusweisAuthEnterPinPresenter.swift
//  OSCA
//
//  Created by Bharat Jagtap on 03/03/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
