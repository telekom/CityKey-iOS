//
//  SCAusweisAuthSuccessPresenter.swift
//  OSCA
//
//  Created by Bharat Jagtap on 01/03/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

protocol SCAusweisAuthSuccessPresenting {
    func setDisplay(display : SCAusweisAuthSuccessViewDisplay)
    func onSuccess()
}

class SCAusweisAuthSuccessPresenter {
    
    weak var display : SCAusweisAuthSuccessViewDisplay?
    var worker : SCAusweisAuthWorking
    var injector : SCAusweisAuthServiceInjecting & SCAdjustTrackingInjection
    
    init(worker : SCAusweisAuthWorking, injector : SCAusweisAuthServiceInjecting & SCAdjustTrackingInjection) {
        self.worker = worker
        self.injector = injector
    }
    
    func viewDidLoad() { }
    
    func viewWillAppear() { }
    
    func viewDidAppear() {
        
        SCFileLogger.shared.write("SCAusweisAuthSuccessPresenter -> viewDidAppear -> succeded, closing the Ausweis Dialog in 3 seconds", withTag: .ausweis)

        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] (timer) in
            self?.onSuccess()
        }
    }
    
}

extension SCAusweisAuthSuccessPresenter : SCAusweisAuthSuccessPresenting {
    
    func setDisplay(display : SCAusweisAuthSuccessViewDisplay) {
        self.display = display
    }
    
    func onSuccess() {
        self.worker.onSuccess()
    }
    
}
