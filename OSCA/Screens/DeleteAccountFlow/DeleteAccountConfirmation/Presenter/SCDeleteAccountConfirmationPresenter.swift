//
//  DeleteAccountConfirmationPresenter.swift
//  SmartCity
//
//  Created by Alexander Lichius on 09.08.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

class SCDeleteAccountConfirmationPresenter {
    let authProvider: SCAuth
    let worker: SCDeleteAccountConfirmationWorking
    let injector: SCDeleteAccountInjecting
    let loginInjector: SCLoginInjecting & SCRegistrationInjecting
    let sharedWorkerInjector: SCSharedWorkerInjecting
    var display: SCDeleteAccountConfirmationDisplaying?
    weak var presentedVC: UIViewController?

    var showPwdSelected: Bool = false {
        didSet {
            self.display?.showPasswordSelected(showPwdSelected)
        }
    }
    
    init(authProvider: SCAuth, injector: SCDeleteAccountInjecting, loginInjector: SCLoginInjecting & SCRegistrationInjecting ,sharedWorkerInjecting: SCSharedWorkerInjecting, worker: SCDeleteAccountConfirmationWorking) {
        self.authProvider = authProvider
        self.injector = injector
        self.loginInjector = loginInjector
        self.sharedWorkerInjector = sharedWorkerInjecting
        self.worker = worker
    }
    
    func subscribeToLogoutNotification() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(userLoggedOut), name: Notification.Name.userDidSignOut, object: nil)
    }
    
    @objc func userLoggedOut() {
        self.display?.popToRootViewController()
    }
    
    func passwordFulfillsCriteria(_ password: String) -> Bool{
        if password.isEmpty {
            self.display?.hideTopLabel()
            self.display?.setConfirmButtonState(.disabled)
            return false
        }
        return true
    }
    
    func getUserProfile() -> SCModelProfile? {
        if authProvider.isUserLoggedIn() {
            return sharedWorkerInjector.getUserContentSharedWorker().getUserData()?.profile
        }
        
        return nil
    }

    private func resetConfirmationButton() {
        self.display?.setupConfirmationButton(title: LocalizationKeys.DeleteAccountConfirmation.d002DeleteAccountValidationButtonText.localized())
    }
    
    private func showErrorScreen() {
        let deleteAccountSuccessViewController = self.injector.getDeleteAccountSuccessController()
        self.display?.push(viewController: deleteAccountSuccessViewController)
    }
    
    func closeButtonWasPressed() {
        self.display?.dismiss(completion: nil)
    }
}
