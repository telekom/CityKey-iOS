//
//  SCDisplaying+DefaultImplementation.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 25.06.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

extension SCDisplaying {
    
    func showErrorDialog(with text: String, retryHandler : (() -> Void)? = nil, showCancelButton: Bool? = true, additionalButtonTitle: String? = nil, additionButtonHandler: (() -> Void)? = nil) {
        SCUtilities.delay(withTime: 1.0, callback: {
            let retryTitle =  retryHandler != nil ? LocalizationKeys.SCEventDetailVC.dialogRetryRetryButton.localized() : nil
            
            let canelTitle = showCancelButton == true ?  LocalizationKeys.SCEventDetailVC.dialogButtonOk.localized() : nil

            if let viewControllerSelf = self as? UIViewController {
                viewControllerSelf.showUIAlert(with: text, cancelTitle: canelTitle , retryTitle: retryTitle, retryHandler: retryHandler, additionalButtonTitle: additionalButtonTitle, additionButtonHandler: additionButtonHandler )
            } else {
                SCUtilities.topViewController().showUIAlert(with: text, cancelTitle: canelTitle , retryTitle: retryTitle, retryHandler: retryHandler, additionalButtonTitle: additionalButtonTitle, additionButtonHandler: additionButtonHandler )
            }
        })
    }

    func showNoInternetAvailableDialog(retryHandler : (() -> Void)? = nil, showCancelButton: Bool? = true, additionalButtonTitle: String? = nil, additionButtonHandler: (() -> Void)? = nil) {
        self.showErrorDialog(with: LocalizationKeys.SCEventDetailVC.dialogRetryDescription.localized(), retryHandler: retryHandler, showCancelButton : showCancelButton, additionalButtonTitle: additionalButtonTitle, additionButtonHandler: additionButtonHandler)
    }
    
    func showCityNotAvailableDialog(retryHandler : (() -> Void)? = nil, showCancelButton: Bool? = false, additionalButtonTitle: String? = nil, additionButtonHandler: (() -> Void)? = nil) {
        let retryTitle =  retryHandler != nil ? LocalizationKeys.SCDisplayingDefaultImplementation.cityNotAvailableDialogOkButton.localized() : nil
        
        let canelTitle = showCancelButton == true ?  LocalizationKeys.SCDisplayingDefaultImplementation.cityNotAvailableDialogOkButton.localized() : nil

        SCUtilities.topViewController().showUIAlert(with: LocalizationKeys.SCDisplayingDefaultImplementation.cityNotAvailableDialogBody.localized(), cancelTitle: canelTitle, retryTitle: retryTitle, retryHandler: retryHandler, additionalButtonTitle: additionalButtonTitle, additionButtonHandler: additionButtonHandler, alertTitle: LocalizationKeys.SCDisplayingDefaultImplementation.cityNotAvailableDialogTitle.localized())
        
    }

    func showErrorDialog(_ error: SCWorkerError, retryHandler : (() -> Void)? = nil, showCancelButton: Bool? = true, additionalButtonTitle: String? = nil, additionButtonHandler: (() -> Void)? = nil) {

        switch error {
        case .unauthorized:
            self.showErrorDialog(with: LocalizationKeys.SCDisplayingDefaultImplementation.dialogAuthenticationErrorMessage.localized(), retryHandler: retryHandler,showCancelButton: showCancelButton, additionalButtonTitle: additionalButtonTitle, additionButtonHandler: additionButtonHandler)
         case .technicalError:
            self.showErrorDialog(with: LocalizationKeys.SCDisplayingDefaultImplementation.dialogTechnicalErrorMessage.localized(), retryHandler: retryHandler,showCancelButton: showCancelButton, additionalButtonTitle: additionalButtonTitle, additionButtonHandler: additionButtonHandler)
        case .noInternet:
            self.showNoInternetAvailableDialog(retryHandler: retryHandler, showCancelButton : showCancelButton, additionalButtonTitle: additionalButtonTitle, additionButtonHandler: additionButtonHandler)
        case .fetchFailed(let errorDetail):
            self.showErrorDialog(with: errorDetail.message, retryHandler: retryHandler, showCancelButton : showCancelButton, additionalButtonTitle: additionalButtonTitle, additionButtonHandler: additionButtonHandler)
        }
    }

}
