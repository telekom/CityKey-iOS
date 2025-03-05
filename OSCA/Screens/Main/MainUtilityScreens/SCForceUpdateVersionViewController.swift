/*
Created by A118572539 on 04/02/22.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, A118572539
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import Foundation
import UIKit

class SCForceUpdateVersionViewController: UIViewController {
    
    @IBOutlet weak var titleLabel : UILabel!
    
    @IBOutlet weak var subtitlelabel : UILabel!
    
    @IBOutlet weak var updateButton: SCCustomButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        setupAccessibility()
    }
    
    private func setupUI() {
        self.updateButton.customizeBlueStyle()
        self.updateButton.setTitle("h_001_update_app".localized(), for: .normal)
        self.updateButton.titleLabel?.adaptFontSize()
        
        self.titleLabel.text = "h_001_update_required".localized()
        self.subtitlelabel.text = "h_001_update_detail_text".localized()
    }
    
    private func setupAccessibility() {
        self.updateButton.accessibilityIdentifier = "btn_update"
        self.updateButton.accessibilityTraits = .button
        self.updateButton.accessibilityLabel = "h_001_update_app".localized()
        self.updateButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.titleLabel.accessibilityIdentifier = "lbl_update_required"
        self.titleLabel.accessibilityTraits = .staticText
        self.titleLabel.accessibilityLabel = "h_001_update_required".localized()
        self.titleLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.subtitlelabel.accessibilityIdentifier = "lbl_update_details"
        self.subtitlelabel.accessibilityTraits = .staticText
        self.subtitlelabel.accessibilityLabel = "h_001_update_detail_text".localized()
        self.subtitlelabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }
    
    @IBAction func updateApp(_ sender: UIButton) {
        if let url = URL(string: "https://apps.apple.com/de/app/citykey/id1516529784"),
           UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
