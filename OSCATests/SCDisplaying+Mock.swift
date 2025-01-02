//
//  SCDisplaying+Mock.swift
//  SmartCityTests
//
//  Created by Michael on 31.07.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
@testable import OSCA

extension SCDisplaying {
    
    func showErrorDialog(with text: String, retryHandler : (() -> Void)? = nil, showCancelButton: Bool? = true, additionalButtonTitle: String? = nil, additionButtonHandler: (() -> Void)? = nil){
        
    }
    
    func showNoInternetAvailableDialog(retryHandler : (() -> Void)? = nil, showCancelButton: Bool? = true, additionalButtonTitle: String? = nil, additionButtonHandler: (() -> Void)? = nil){
        
    }
    
    func showErrorDialog(_ error: SCWorkerError, retryHandler : (() -> Void)? = nil, showCancelButton: Bool? = true, additionalButtonTitle: String? = nil, additionButtonHandler: (() -> Void)? = nil){
        
    }

    func showCityNotAvailableDialog(retryHandler : (() -> Void)?, showCancelButton: Bool?, additionalButtonTitle: String?, additionButtonHandler: (() -> Void)?){
        
    }

}
