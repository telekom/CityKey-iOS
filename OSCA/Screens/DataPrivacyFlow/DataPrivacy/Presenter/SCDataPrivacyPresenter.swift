/*
Created by Michael on 01.02.20.
Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

class SCDataPrivacyPresenter {
    
    weak private var display: SCDataPrivacyDisplaying?
    private let injector: SCAdjustTrackingInjection & SCLegalInfoInjecting
    
    private let showCloseBtn : Bool
    private var appContentSharedWorker: SCAppContentSharedWorking

    private let preventSwipeToDismiss : Bool
    private let shouldPushSettingsController : Bool
    
    init(appContentSharedWorker: SCAppContentSharedWorking, injector: SCAdjustTrackingInjection & SCLegalInfoInjecting, showCloseBtn : Bool , preventSwipeToDismiss : Bool , shouldPushSettingsController : Bool) {
        
        self.appContentSharedWorker = appContentSharedWorker
        self.showCloseBtn = showCloseBtn
        self.injector = injector
        self.preventSwipeToDismiss = preventSwipeToDismiss
        self.shouldPushSettingsController = shouldPushSettingsController
    }
        
}

extension SCDataPrivacyPresenter: SCPresenting {
    func viewDidLoad() {
        prepareAndRefreshUI()
    }
    
    func prepareAndRefreshUI() {
        var topText = NSAttributedString(string: "")
        var bottomText = NSAttributedString(string: "")
        
            if let attrStringTop =  self.appContentSharedWorker.getDataSecurity()?.dataUsage.htmlAttributedString {
                let htmlAttrToptring = NSMutableAttributedString(attributedString: attrStringTop)
                htmlAttrToptring.replaceFont(with: UIFont.SystemFont.regular.forTextStyle(style: .body, size: 15.0, maxSize: 22.0), color: UIColor(named: "CLR_LABEL_TEXT_BLACK")!)
                topText = htmlAttrToptring

            }
            if let attrStringBottom =  self.appContentSharedWorker.getDataSecurity()?.dataUsage2.htmlAttributedString {
                let htmlAttrBottomString = NSMutableAttributedString(attributedString: attrStringBottom)
                htmlAttrBottomString.replaceFont(with: UIFont.SystemFont.regular.forTextStyle(style: .body, size: 15.0, maxSize: 22.0), color: UIColor(named: "CLR_LABEL_TEXT_BLACK")!)
                bottomText = htmlAttrBottomString
            }
        
        if self.preventSwipeToDismiss {
            self.display?.preventSwipeToDismiss()
        }
        
        self.display?.setupUI(title: LocalizationKeys.SCDataPrivacy.x001WelcomeBtnPrivacyShort.localized().localized(),
                              showCloseBtn: self.showCloseBtn,
                              topText:  self.appContentSharedWorker.getDataSecurity()?.dataUsage ?? "",
                              bottomText: self.appContentSharedWorker.getDataSecurity()?.dataUsage2 ?? "",
                              displayActIndicator : true,
                              appVersion: SCUtilities.currentVersionAndEnv())
    }
}

extension SCDataPrivacyPresenter : SCDataPrivacyPresenting {
    
    func setDisplay(_ display: SCDataPrivacyDisplaying) {
        self.display = display
    }
    
    func closeBtnWasPressed(){
        self.display?.dismiss()
    }

    func saveBtnWasPressed(){
        self.appContentSharedWorker.trackingPermissionFinished = true
        self.display?.dismiss()
    }
    
    func settingsButtonPressed() {
     
        if shouldPushSettingsController {
            let controller = injector.getDataPrivacySettingsController(shouldPushDataPrivacyController: false, preventSwipeToDismiss: self.preventSwipeToDismiss, isFirstRunSettings: false, completionHandler: nil)
            display?.push(controller)
        } else {
            display?.popViewController()
        }
    }
    
}

