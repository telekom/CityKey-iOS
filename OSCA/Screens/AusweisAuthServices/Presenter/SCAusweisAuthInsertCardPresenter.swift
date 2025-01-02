//
//  SCAusweisAuthInsertCardPresenter.swift
//  OSCA
//
//  Created by Bharat Jagtap on 01/03/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

protocol SCAusweisAuthInsertCardPresenting : SCPresenting {
    func setDisplay(display : SCAusweisAuthInsertCardDisplay)
}

class SCAusweisAuthInsertCardPresenter {
    weak var display : SCAusweisAuthInsertCardDisplay!
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

extension SCAusweisAuthInsertCardPresenter : SCAusweisAuthInsertCardPresenting {
    
    func setDisplay(display : SCAusweisAuthInsertCardDisplay) {
        self.display = display
    }    
    
}
