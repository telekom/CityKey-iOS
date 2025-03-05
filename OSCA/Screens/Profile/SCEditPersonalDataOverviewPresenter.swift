/*
Created by Harshada Deshmukh on 15/02/21.
Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Harshada Deshmukh
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit
import TTGSnackbar

protocol SCEditPersonalDataOverviewDisplaying: AnyObject, SCDisplaying {
    func setupNavigationBar(title: String)
    func setupUI(postcode: String, profile: SCModelProfile)
    func push(viewController: UIViewController)
    func dismiss(completion: (() -> Void)?)

}

protocol SCEditPersonalDataOverviewPresenting: SCPresenting {
    func setDisplay(_ display: SCEditPersonalDataOverviewDisplaying)
    
    func editDateOfBirthWasPressed()
    func editResidenceWasPressed()
    func closeButtonWasPressed()
    func displayToastWith(message: String)

}

class SCEditPersonalDataOverviewPresenter{
    
    weak private var display : SCEditPersonalDataOverviewDisplaying?
    
    private let personalDataEditOverviewWorker: SCEditPersonalDataOverviewWorking
    private let userContentSharedWorker: SCUserContentSharedWorking
    private let authProvider: SCLogoutAuthProviding
    private let injector: SCEditProfileInjecting //SCEditPersonalDataInjecting
    private var postcode: String
    private var profile: SCModelProfile?
    private var finishViewController : UIViewController?
    
    init(postcode: String, profile: SCModelProfile, personalDataEditOverviewWorker: SCEditPersonalDataOverviewWorking, userContentSharedWorker: SCUserContentSharedWorking, authProvider: SCLogoutAuthProviding, injector: SCEditProfileInjecting) {
        
        self.personalDataEditOverviewWorker = personalDataEditOverviewWorker
        self.userContentSharedWorker = userContentSharedWorker
        self.authProvider = authProvider
        self.injector = injector
        self.postcode = postcode
        self.profile = profile
        
        self.setupNotifications()
    }
    
    deinit {
    }

    private func setupUI() {
        self.display?.setupNavigationBar(title: "p_001_profile_label_personal_data".localized())
        self.display?.setupUI(postcode: self.postcode, profile: self.profile!)
    }
    
    private func setupNotifications() {
        
    }
    
    private func updateContent(){
        self.profile = SCUserDefaultsHelper.getProfile()
        self.display?.setupUI(postcode: self.profile?.postalCode ?? "", profile: self.profile!)
    }
    
    private func triggerUserDataUpdate() {
        debugPrint("SCProfilePresenter->triggerUserDataUpdate")
        
        if authProvider.isUserLoggedIn(){
            self.userContentSharedWorker.triggerUserDataUpdate { (error) in
                                
                if error != nil {
                    
                    self.display?.showErrorDialog(error!, retryHandler : { self.triggerUserDataUpdate() }, additionalButtonTitle: "p_001_profile_btn_logout".localized(), additionButtonHandler : nil)
                }
            }
       }
    }
}

extension SCEditPersonalDataOverviewPresenter: SCPresenting {
    
    func viewDidLoad() {
        debugPrint("SCEditPersonalDataOverviewPresenter->viewDidLoad")
        self.setupUI()
    }
    
    func viewWillAppear() {
        debugPrint("SCEditPersonalDataOverviewPresenter->viewWillAppear")
        self.updateContent()
        self.triggerUserDataUpdate()
    }
    
    func viewDidAppear() {
        
    }
    
    
}

extension SCEditPersonalDataOverviewPresenter: SCEditPersonalDataOverviewPresenting {

    func setDisplay(_ display: SCEditPersonalDataOverviewDisplaying) {
        self.display = display
    }
    
    func editDateOfBirthWasPressed(){
        
        self.display?.push(viewController: self.injector.getProfileEditDateOfBirthViewController(in: .editProfile,
                                                                                                 completionHandler: nil) )
        //self.displayToastWith(message: "p_001_profile_residence_snackbar_message".localized())
    }
    
    func editResidenceWasPressed(){
        self.display?.push(viewController: self.injector.getProfileEditResidenceViewController(postcode: postcode))
    }

    func closeButtonWasPressed() {
        self.display?.dismiss(completion: nil)
    }
    
    func displayToastWith(message: String) {
        let snackbar = TTGSnackbar(
            message: message,
            duration: .middle
        )

        snackbar.setCustomStyle()
        snackbar.show()
    }
}
