/*
Created by Bhaskar N S on 07/07/22.
Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Bhaskar N S
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

extension SCDataPrivacySettingsViewController : SCDataPrivacySettingsDisplay {
    
    func setupUI(navigationTitle: String,
                 title: String,
                 description: String,
                 moengageTitle: String,
                 moengageDescription: String,
                 adjustTitle: String,
                 adjustDescription: String,
                 adjustEnabled: Bool) {
        
        self.navigationItem.title = navigationTitle
        self.titleLabel.attributedText = title.applyHyphenation()
        self.descriptionLabel.attributedText = description.applyHyphenation()
        self.adjustOptionView.permissionSwitch.isOn = adjustEnabled
        self.moengageOptionView.titleLabel.text = moengageTitle
        self.moengageOptionView.descriptionLabel.attributedText = moengageDescription.applyHyphenation()
        self.adjustOptionView.titleLabel.text = adjustTitle
        self.adjustOptionView.descriptionLabel.attributedText = adjustDescription.applyHyphenation()
        self.adjustOptionView.permissionSwitch.isOn = adjustEnabled
        
    }
    
    func preventSwipeToDismiss() {
        
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
    }
    
    func dismiss() {
                
        self.dismiss(animated: true, completion: nil)
    }
    
    func push(_ controller : UIViewController) {
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func popViewController() {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func dismiss(completionHandler: (() -> Void)?) {
        self.dismiss(animated: true, completion: completionHandler)
    }
    
}
