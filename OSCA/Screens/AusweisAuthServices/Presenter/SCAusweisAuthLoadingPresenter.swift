//
//  SCAusweisAuthLoadingPresenter.swift
//  OSCA
//
//  Created by Bharat Jagtap on 25/02/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

protocol SCAusweisAuthLoadingPresenting : SCPresenting {
    
    func setDisplay(display : SCAusweisAuthLoadingDisplay)
}


class SCAusweisAuthLoadingPresenter  {
    
    var workflowDisplay : SCAusweisAuthWorkFlowDisplay?
    private var worker : SCAusweisAuthWorking
    weak var display : SCAusweisAuthLoadingDisplay!
    private let cityContentSharedWorker: SCCityContentSharedWorking
    private let injector: SCAusweisAuthServiceInjecting


    init(worker : SCAusweisAuthWorking , cityContentSharedWorker: SCCityContentSharedWorking, injector: SCAusweisAuthServiceInjecting) {
        
        self.worker = worker
        self.cityContentSharedWorker = cityContentSharedWorker
        self.injector = injector
        
    }
    
}

extension SCAusweisAuthLoadingPresenter : SCAusweisAuthLoadingPresenting {
    
    func setDisplay(display: SCAusweisAuthLoadingDisplay) {
        self.display = display
    }
    
    func viewDidLoad() {
        
        
    }
    
    func viewWillAppear() {
        
        
    }
    
    func viewDidAppear() {

    }
    

}
