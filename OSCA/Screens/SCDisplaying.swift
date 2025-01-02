//
//  SCDisplaying.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 25.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

enum SCDisplayContentType {
    case news
    case proposal
    case service
    case marketplace
}

protocol SCDisplaying {
    func showErrorDialog(with text: String, retryHandler : (() -> Void)?, showCancelButton: Bool?, additionalButtonTitle: String?, additionButtonHandler: (() -> Void)?)
    
    func showNoInternetAvailableDialog(retryHandler : (() -> Void)?, showCancelButton: Bool?, additionalButtonTitle: String?, additionButtonHandler: (() -> Void)?)
    
    func showErrorDialog(_ error: SCWorkerError, retryHandler : (() -> Void)?, showCancelButton: Bool?, additionalButtonTitle: String?, additionButtonHandler: (() -> Void)?)

    func showCityNotAvailableDialog(retryHandler : (() -> Void)?, showCancelButton: Bool?, additionalButtonTitle: String?, additionButtonHandler: (() -> Void)?) 
}
