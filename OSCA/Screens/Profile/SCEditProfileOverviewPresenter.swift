/*
Created by Michael on 21.06.19.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

protocol SCEditProfileOverviewDisplaying: AnyObject {
    func setupNavigationBar(title: String)
    func setupUI(email: String)
    func push(viewController: UIViewController)
    func dismiss(completion: (() -> Void)?)

}

protocol SCEditProfileOverviewPresenting: SCPresenting {
    func setDisplay(_ display: SCEditProfileOverviewDisplaying)
    
    func editPWDWasPressed()
    func editEMailWasPressed()
    func deleteAccountWasPressed()
    func closeButtonWasPressed()

}

enum DateOfBirth: String {
    case editProfile
    case registration
}

class SCEditProfileOverviewPresenter: NSObject {
    
    weak private var display : SCEditProfileOverviewDisplaying?
    
    private let profileEditOverviewWorker: SCEditProfileOverviewWorking
    private let injector: SCEditProfileInjecting
    private var email: String
    private var finishViewController : UIViewController?
    
    init(email: String, profileEditOverviewWorker: SCEditProfileOverviewWorking, injector: SCEditProfileInjecting) {
        
        self.profileEditOverviewWorker = profileEditOverviewWorker
        self.injector = injector
        self.email = email
        
        super.init()
        
        self.setupNotifications()
    }
    
    deinit {
    }

    private func setupUI() {
        self.display?.setupNavigationBar(title: "p_001_profile_label_account_settings".localized())
        self.display?.setupUI(email: self.email)
    }
    
    private func setupNotifications() {
        
    }
    
    
}

extension SCEditProfileOverviewPresenter: SCPresenting {
    
    func viewDidLoad() {
        debugPrint("SCEditProfileOverviewPresenter->viewDidLoad")
        self.setupUI()
    }
    
    func viewWillAppear() {
        debugPrint("SCEditProfileOverviewPresenter->viewWillAppear")
    }
    
    func viewDidAppear() {
        
    }
    
    
}

extension SCEditProfileOverviewPresenter: SCEditProfileOverviewPresenting {
    func deleteAccountWasPressed() {
        self.display?.push(viewController: self.injector.getDeleteAccountViewController())
    }
    
    
    func setDisplay(_ display: SCEditProfileOverviewDisplaying) {
        self.display = display
    }
    
    func editPWDWasPressed(){
        self.display?.push(viewController: self.injector.getProfileEditPasswordViewController(email: email))
        
    }
    
    func editEMailWasPressed(){
        self.display?.push(viewController: self.injector.getProfileEditEMailViewController(email: email))
    }

    func closeButtonWasPressed() {
        self.display?.dismiss(completion: nil)
    }
}
