/*
Created by Michael on 29.03.19.
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

class SCEditPasswordFinishedVC: UIViewController {

    public var presenter: SCEditPasswordFinishedPresenting!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var finishBtn: SCCustomButton!
    @IBOutlet weak var closeBtn: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
        
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.closeBtn.accessibilityIdentifier = "btn_close"
        self.titleLabel.accessibilityIdentifier = "lbl_title"
        self.detailLabel.accessibilityIdentifier = "lbl_detail"
        self.finishBtn?.accessibilityIdentifier = "btn_finish"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }
    
    private func setupAccessibility(){
        self.closeBtn.accessibilityTraits = .button
        self.closeBtn.accessibilityLabel = "accessibility_btn_close".localized()
        self.closeBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }
    
    
    @IBAction func finishBtnWasPressed(_ sender: Any) {
        self.presenter.finishWasPressed()
    }
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        self.presenter.closeButtonWasPressed()
    }
}

extension SCEditPasswordFinishedVC: SCEditPasswordFinishedDisplaying {
    
    func setupUI() {
        self.navigationItem.title = "p_005_profile_password_change_title".localized()
        
        self.titleLabel.adaptFontSize()
        self.titleLabel.text = "p_006_profile_password_changed_info_done".localized()
        self.detailLabel.adaptFontSize()
        self.detailLabel.text = "p_006_profile_password_changed_info_next".localized()
        self.finishBtn.customizeBlueStyle()
        self.finishBtn.setTitle("r_005_registration_success_login_btn".localized(), for: .normal)
        self.finishBtn.titleLabel?.adaptFontSize()
        
        titleLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .title3, size: 20, maxSize: 30)
        detailLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 14, maxSize: 30)
        
        // remove the Back button
        self.navigationItem.hidesBackButton = true
        
        self.view.setNeedsLayout()
    }
    
    func dismissView(completion: (() -> Void)? = nil) {
        self.dismiss(animated: false, completion: completion)
    }

    func setFinishButtonState(_ state : SCCustomButtonState){
        self.finishBtn.btnState = state
    }

    func dismiss(completion: (() -> Void)?) {
        self.dismiss(animated: true, completion: completion)
    }
}
