//
//  SCAusweisHelpPresenter.swift
//  OSCA
//
//  Created by Bharat Jagtap on 16/03/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit
protocol SCAusweisAuthHelpPresenting : SCPresenting {
    
    func setDisplay(display : SCAusweisAuthHelpViewDisplay)
    func onDownloadAusweisAppClick()
    func onCallAusweisHelpClick()
}

class SCAusweisAuthHelpPresenter {
    
    private weak var display : SCAusweisAuthHelpViewDisplay!
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

extension SCAusweisAuthHelpPresenter : SCAusweisAuthHelpPresenting {
    func setDisplay(display : SCAusweisAuthHelpViewDisplay) {
        self.display = display
    }
    
    func onDownloadAusweisAppClick() {
     
        if let url = URL(string: GlobalConstants.Ausweis.ausweisAppStoreURL) {
            UIApplication.shared.open(url, options: [:] , completionHandler: nil)
        }
    }
    
    func onCallAusweisHelpClick() {
        
        if let url = URL(string: GlobalConstants.Ausweis.ausweisAppHelpURL) {            
            UIApplication.shared.open(url, options: [:] , completionHandler: nil)
        }
    }

}

