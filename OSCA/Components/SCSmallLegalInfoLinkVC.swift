/*
Created by Michael on 14.04.19.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Copyright © 2018 Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

enum LinkStyle: Int {
    case dark = 0
    case light = 1
}
protocol SCSmallLegalInfoLinkVCDelegate: AnyObject {
    func impressumButtonWasPressed()
    func dataPrivacyButtonWasPressed()
}

class SCSmallLegalInfoLinkVC: UIViewController {

    weak var linkDelegate: SCSmallLegalInfoLinkVCDelegate?
    
    @IBOutlet weak var impressumBtn: UIButton!
    @IBOutlet weak var dataPrivacyBtn: UIButton!
    
    var linkStyle : LinkStyle = .dark {
        didSet {
            self.refreshStyle()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshStyle()
        self.impressumBtn.setTitle("p_001_profile_btn_imprint".localized(), for: .normal)
        self.impressumBtn.titleLabel?.adaptFontSize()
        self.dataPrivacyBtn.setTitle("l_001_login_btn_privacy_short".localized(), for: .normal)
        self.dataPrivacyBtn.titleLabel?.adaptFontSize()
        self.setupAccessibilityIDs()
        self.setupAccessibility()
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.impressumBtn.accessibilityIdentifier = "btn_impressum"
        self.dataPrivacyBtn.accessibilityIdentifier = "btn_data_privacy"
    }

    private func setupAccessibility(){
        self.impressumBtn.accessibilityTraits = .button
        self.impressumBtn.accessibilityLabel = "p_001_profile_btn_imprint".localized()
        self.impressumBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.dataPrivacyBtn.accessibilityTraits = .button
        self.dataPrivacyBtn.accessibilityLabel = "l_001_login_btn_privacy_short".localized()
        self.dataPrivacyBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
     }

    private func refreshStyle() {
        if self.dataPrivacyBtn != nil && self.impressumBtn != nil{
            switch linkStyle {
            case .dark:
                impressumBtn.setTitleColor(UIColor(named: "CLR_LABEL_TEXT_BLACK")!, for: .normal)
                impressumBtn.setTitleColor(UIColor(named: "CLR_LABEL_TEXT_BLACK")!, for: .highlighted)
                dataPrivacyBtn.setTitleColor(UIColor(named: "CLR_LABEL_TEXT_BLACK")!, for: .normal)
                dataPrivacyBtn.setTitleColor(UIColor(named: "CLR_LABEL_TEXT_BLACK")!, for: .highlighted)
                dataPrivacyBtn.setImage(UIImage(named: "icon_datenschutz_dark"), for: .normal)
            case .light:
                impressumBtn.setTitleColor(UIColor(white: 1.0, alpha: 0.75), for: .normal)
                impressumBtn.setTitleColor(UIColor(white: 1.0, alpha: 1.0), for: .highlighted)
                dataPrivacyBtn.setTitleColor(UIColor(white: 1.0, alpha: 0.75), for: .normal)
                dataPrivacyBtn.setTitleColor(UIColor(white: 1.0, alpha: 1.0), for: .highlighted)
                dataPrivacyBtn.setImage(UIImage(named: "icon_datenschutz_light"), for: .normal)
                dataPrivacyBtn.setImage(UIImage(named: "icon_datenschutz_light"), for: .highlighted)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func impressumBtnWasPressed(_ sender: Any) {
        self.linkDelegate?.impressumButtonWasPressed()
    }
    
    @IBAction func dataPrivacyBtnWasPressed(_ sender: Any) {
        self.linkDelegate?.dataPrivacyButtonWasPressed()
    }
}
