/*
Created by Alexander Lichius on 09.08.19.
Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 
In accordance with Sections 4 and 6 of the License, the following exclusions apply:

    1. Trademarks & Logos – The names, logos, and trademarks of the Licensor are not covered by this License and may not be used without separate permission.
    2. Design Rights – Visual identities, UI/UX designs, and other graphical elements remain the property of their respective owners and are not licensed under the Apache License 2.0.
    3: Non-Coded Copyrights – Documentation, images, videos, and other non-software materials require separate authorization for use, modification, or distribution.

These elements are not considered part of the licensed Work or Derivative Works unless explicitly agreed otherwise. All elements must be altered, removed, or replaced before use or distribution. All rights to these materials are reserved, and Contributor accepts no liability for any infringing use. By using this repository, you agree to indemnify and hold harmless Contributor against any claims, costs, or damages arising from your use of the excluded elements.

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Alexander Lichius
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

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
