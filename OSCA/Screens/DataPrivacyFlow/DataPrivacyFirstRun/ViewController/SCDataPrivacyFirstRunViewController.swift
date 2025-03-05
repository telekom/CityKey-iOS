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

import UIKit

class SCDataPrivacyFirstRunViewController: UIViewController {
    
    var presenter : SCDataPrivacyFirstRunPresenting!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var changeSettingsButton : SCCustomButton!
    @IBOutlet weak var acceptAllButton : SCCustomButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupAccessibility()
        presenter.setDisplay(self)
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshNavigationBarStyle()
        presenter.viewWillAppear()
    }
    
    func setupUI() {
        
        changeSettingsButton.customizeBlueStyleLight()
        acceptAllButton.customizeBlueStyle()
        changeSettingsButton.setTitle(LocalizationKeys.DataPrivacyFirstRun.dialogDpnSettingsChangeBtn.localized(), for: .normal)
        acceptAllButton.setTitle(LocalizationKeys.DataPrivacyFirstRun.dialogDpnSettingsAcceptAllBtn.localized(), for: .normal)
        
        descriptionLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .callout, size: 16, maxSize: nil)

        changeSettingsButton.titleLabel?.adjustsFontForContentSizeCategory = true
        changeSettingsButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .subheadline, size: 15, maxSize: (UIScreen.main.bounds.size.width) == 320 ? 22.0 : 30.0)

        acceptAllButton.titleLabel?.adjustsFontForContentSizeCategory = true
        acceptAllButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .subheadline, size: 15, maxSize: (UIScreen.main.bounds.size.width) == 320 ? 22.0 : 30.0)
    }
    
    func setupAccessibility() {
        
        descriptionLabel.accessibilityTraits = .staticText
        descriptionLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        changeSettingsButton.accessibilityTraits = .button
        changeSettingsButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        acceptAllButton.accessibilityTraits = .button
        acceptAllButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
    }
    
    @IBAction func changeSettingsClicked(_ sender: Any) {
        presenter.changeSettingsPressed()
    }
    
    
    @IBAction func acceptAllClicked(_ sender: Any) {
        presenter.acceptAllPressed()
    }
}
