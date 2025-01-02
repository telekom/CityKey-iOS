//
//  SCAusweisAuthNeedPukPresenter.swift
//  OSCA
//
//  Created by Bharat Jagtap on 19/03/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

protocol SCAusweisAuthNeedPukPresenting : SCPresenting {

    func setDisplay(display : SCAusweisAuthNeedPukViewDisplay)
    func onSubmitClick()
}

class SCAusweisAuthNeedPukPresenter {

    weak var display : SCAusweisAuthNeedPukViewDisplay?
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

extension SCAusweisAuthNeedPukPresenter : SCAusweisAuthNeedPukPresenting {
    
    func setDisplay(display : SCAusweisAuthNeedPukViewDisplay) {
        
        self.display = display
    }
    
    func onSubmitClick() {
        
        worker.onSubmitPUKInfoRead()
    }
}
