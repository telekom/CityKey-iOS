//
//  SCAusweisCardBlockedPresenter.swift
//  OSCA
//
//  Created by Bharat Jagtap on 24/03/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

protocol SCAusweisAuthCardBlockedPresenting : SCPresenting {
    func setDisplay(display : SCAusweisAuthCardBlockedViewDisplay)
    func onSubmitClicked()
}

class SCAusweisAuthCardBlockedPresenter {
    private weak var display : SCAusweisAuthCardBlockedViewDisplay!
    var worker : SCAusweisAuthWorking
    var injector : SCAusweisAuthServiceInjecting
    
    init(worker : SCAusweisAuthWorking, injector : SCAusweisAuthServiceInjecting) {
        self.worker = worker
        self.injector = injector
    }
    
    func viewDidLoad() {

    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }

}

extension SCAusweisAuthCardBlockedPresenter : SCAusweisAuthCardBlockedPresenting {
    
    func setDisplay(display: SCAusweisAuthCardBlockedViewDisplay) {
        self.display = display
    }
    
    func onSubmitClicked() {
        self.worker.onCardblockedOkClicked()
    }
}
