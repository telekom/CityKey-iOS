/*
Created by Bharat Jagtap on 30/06/21.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Bharat Jagtap
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import Foundation
import UIKit

class SCDataPrivacyFirstRunPresenter {
    
    weak private var display: SCDataPrivacyFirstRunDisplay?
    private var appContentSharedWorker: SCAppContentSharedWorking
    private var injector : SCLegalInfoInjecting
    private let preventSwipeToDismiss: Bool
    var completionHandler: (() -> Void)?
    
    init(appContentSharedWorker: SCAppContentSharedWorking , injector : SCLegalInfoInjecting , preventSwipeToDismiss : Bool) {
        
        self.appContentSharedWorker = appContentSharedWorker
        self.injector = injector
        self.preventSwipeToDismiss = preventSwipeToDismiss
    }

    
}

extension SCDataPrivacyFirstRunPresenter : SCDataPrivacyFirstRunPresenting {
  
    func setDisplay(_ display: SCDataPrivacyFirstRunDisplay) {
        self.display = display
    }
    
    func changeSettingsPressed() {
        
        let viewController = self.injector.getDataPrivacySettingsController(shouldPushDataPrivacyController: true, preventSwipeToDismiss: true,
                                                                            isFirstRunSettings: true, completionHandler: completionHandler)
        display?.navigateTo(viewController)
        
    }
    
    func acceptAllPressed() {
        
        self.appContentSharedWorker.privacyOptOutMoEngage = true
        self.appContentSharedWorker.privacyOptOutAdjust = false
        self.appContentSharedWorker.trackingPermissionFinished = true
        display?.dismiss(completion: completionHandler)
        
    }
    
    func acceptSelectedLinkPressed() {
      
        self.appContentSharedWorker.privacyOptOutMoEngage = true
        self.appContentSharedWorker.privacyOptOutAdjust = true
        self.appContentSharedWorker.trackingPermissionFinished = true
        display?.dismiss(completion: completionHandler)
    }
    
    func dataPrivacyNoticeLinkPressed() {
        
        let viewController = self.injector.getDataPrivacyController(preventSwipeToDismiss: true, shouldPushSettingsController: true)
        display?.navigateTo(viewController)
    }
    
    func viewDidLoad() {
        
        if preventSwipeToDismiss {
            display?.preventSwipeToDismiss()
        }
     
        display?.setupUI(navigationTitle: LocalizationKeys.DataPrivacySettings.dialogDpnSettingsTitle.localized(),
                         description: LocalizationKeys.DataPrivacyFirstRun.dialogDpnFtuTextFormat.localized())
    }
}
