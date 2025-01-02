//
//  SCDeleteAccountPresenter.swift
//  SmartCity
//
//  Created by Alexander Lichius on 08.08.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

class SCDeleteAccountPresenter: SCDeleteAccountPresenting {
    func setDisplay(_ display: SCDeleteAccountDisplaying) {
        self.display = display
    }
    
    var display: SCDeleteAccountDisplaying!
    var injector: SCDeleteAccountInjecting & SCAdjustTrackingInjection
    
    init(injector: SCDeleteAccountInjecting & SCAdjustTrackingInjection) {
        self.injector = injector
    }
    
    func setupUI() {
        self.display?.setupNavTitle(with: LocalizationKeys.DeleteAccount.d001DeleteAccountInfoTitle.localized())
        self.display?.setupTitleLabel(with: LocalizationKeys.DeleteAccount.d001DeleteAccountInfo.localized())
        self.display?.setupDeleteAccountButton(with: LocalizationKeys.DeleteAccount.d001DeleteAccountInfoButtonText.localized())
        self.display?.setupDescriptionLabel(with: LocalizationKeys.DeleteAccount.d001DeleteAccountInfo1.localized())
        
    }
    
    func deleteAccountButtonWasPressed() {
        //do I have to check here if user session is still valid to get to the next screen?
        //let viewController = //get the new view controller from the injector, for now just debugPrint
        //self.injector.trackEvent(eventName: "ClickDeleteAccountConfirmBtn")
        let deleteAccountConfirmationViewController = self.injector.getDeleteAccountConfirmationController()
        self.display?.push(viewController: deleteAccountConfirmationViewController)
        debugPrint("deleteAccountButtonPressed")
    }
    
    func closeButtonWasPressed() {
        self.display?.dismiss(completion: nil)
    }
    
}

extension SCDeleteAccountPresenter: SCPresenting {
    func viewDidLoad() {
        self.setupUI()
    }
}
