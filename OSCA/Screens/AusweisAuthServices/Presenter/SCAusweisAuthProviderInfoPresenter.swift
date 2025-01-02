//
//  SCAusweisAuthProviderInfoPresenter.swift
//  OSCA
//
//  Created by Bharat Jagtap on 16/03/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

protocol SCAusweisAuthProviderInfoPresenting : SCPresenting {
    
    func setDisplay(display : SCAusweisAuthProviderInfoDisplay)
    func onProviderLinkClicked()
    func onIssuerLinkClicked()
}

class SCAusweisAuthProviderInfoPresenter {

    private weak var display : SCAusweisAuthProviderInfoDisplay!
    var worker : SCAusweisAuthWorking
    var injector : SCAusweisAuthServiceInjecting
    
    init(worker : SCAusweisAuthWorking, injector : SCAusweisAuthServiceInjecting) {
        self.worker = worker
        self.injector = injector
    }
    
    func viewDidLoad() {

        self.display.setProvider(self.worker.state.certificate?.subjectName ?? "")
        self.display.setProviderLink(self.worker.state.certificate?.subjectUrl ?? "")
        self.display.setIssuer(self.worker.state.certificate?.issuerName ?? "")
        self.display.setIssuerLink(self.worker.state.certificate?.issuerUrl ?? "")
        self.display.setProviderInfo(self.worker.state.certificate?.termsOfUsage ?? "")
        
        if let effectiveDate = self.worker.state.certificate?.effectiveDate , let expiryDate = self.worker.state.certificate?.expirationDate {
            self.display.setValidity("\(effectiveDate) - \(expiryDate)")
        } else {
            self.display.setValidity("")
        }
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
    
}

extension SCAusweisAuthProviderInfoPresenter : SCAusweisAuthProviderInfoPresenting {
    
    func setDisplay(display : SCAusweisAuthProviderInfoDisplay) {
        self.display = display
    }
    
    func onProviderLinkClicked() {
        
        if let link = URL(string:self.worker.state.certificate?.subjectUrl ?? "" ) {
            UIApplication.shared.open(link, options: [:] , completionHandler: nil)
        }
    }
    
    func onIssuerLinkClicked() {

        if let link = URL(string:self.worker.state.certificate?.issuerUrl ?? "" ) {
            UIApplication.shared.open(link, options: [:] , completionHandler: nil)
        }

    }
}
