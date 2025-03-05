/*
Created by Bharat Jagtap on 21/05/21.
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

class SCDataPrivacyNoticePresenter {
    
    weak private var display: SCDataPrivacyNoticeDisplay?
    private var appContentSharedWorker: SCAppContentSharedWorking
    private var injector : SCLegalInfoInjecting
    
    init(appContentSharedWorker: SCAppContentSharedWorking , injector : SCLegalInfoInjecting ) {
        
        self.appContentSharedWorker = appContentSharedWorker
        self.injector = injector
    }

    private func getDPNAttributedText() -> NSAttributedString? {
        
        if let attrString =  appContentSharedWorker.getDataSecurity()?.noticeText.htmlAttributedString?.trimmedAttributedString(set: .whitespacesAndNewlines) {
            
            let htmlAttributedString = NSMutableAttributedString(attributedString: attrString)
            
            htmlAttributedString.replaceFont(with: UIFont.systemFont(ofSize: (UIScreen.main.bounds.size.width) == 320 ? 14.0 : 16.0, weight: UIFont.Weight.medium), color: UIColor(named: "CLR_LABEL_TEXT_BLACK")!)
            
            return htmlAttributedString
        }
        return nil

    }
}

extension SCDataPrivacyNoticePresenter : SCDataPrivacyNoticePresenting {
        
    func viewDidLoad() {
        
        display?.updateDPNText(self.getDPNAttributedText() ?? NSAttributedString(string: ""))
        display?.setTitle(LocalizationKeys.SCDataPrivacyNotice.dialogDpnUpdatedTitle.localized())
    }

    func onAcceptClicked() {
        self.appContentSharedWorker.acceptDataPrivacyNoticeChange { [weak self] (error, result) in
            guard let strongSelf = self else {
                return
            }
            if let error = error  {
                
                strongSelf.display?.resetAcceptButtonState()
                strongSelf.display?.showErrorDialog(error, retryHandler: {
                    self?.onAcceptClicked()
                },
                                                    showCancelButton: true,
                                                    additionalButtonTitle: nil,
                                                    additionButtonHandler: nil)
            } else if 1 == ( result ?? -1 ) {
                strongSelf.display?.dismiss()
            } else {
                
                strongSelf.display?.resetAcceptButtonState()
                strongSelf.display?.showErrorDialog(with: LocalizationKeys.SCDataPrivacyNotice.dialogTechnicalErrorMessage.localized(),
                                               retryHandler: nil,
                                                    showCancelButton: true,
                                                    additionalButtonTitle: nil, additionButtonHandler: nil )
            }
        }
    }
    
    func onShowNoticeClicked() {
        let viewController = injector.getDataPrivacyController(preventSwipeToDismiss: true, shouldPushSettingsController: true)
        display?.push(viewController)
    }
    
    func setDisplay(_ display : SCDataPrivacyNoticeDisplay) {
        self.display = display
    }
}
