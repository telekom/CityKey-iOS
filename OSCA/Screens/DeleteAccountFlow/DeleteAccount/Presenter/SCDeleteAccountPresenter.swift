/*
Created by Alexander Lichius on 08.08.19.
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
