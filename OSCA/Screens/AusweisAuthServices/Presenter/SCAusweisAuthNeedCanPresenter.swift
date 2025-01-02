//
//  SCAusweisAuthNeedCanPresenter.swift
//  OSCA
//
//  Created by Bharat Jagtap on 18/03/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

protocol SCAusweisAuthNeedCanPresenting : SCPresenting {

    func setDisplay(display : SCAusweisAuthNeedCanViewDisplay)
    func onSubmitClick()
}

class SCAusweisAuthNeedCanPresenter {

    weak var display : SCAusweisAuthNeedCanViewDisplay?
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

extension SCAusweisAuthNeedCanPresenter : SCAusweisAuthNeedCanPresenting {
    
    func setDisplay(display : SCAusweisAuthNeedCanViewDisplay) {
        self.display = display
    }
    
    func onSubmitClick() {
        
        worker.onSubmitCANInfoRead()
    }    
}
