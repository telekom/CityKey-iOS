/*
Created by Bharat Jagtap on 24/03/21.
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

protocol SCAusweisAuthCardBlockedViewDisplay : AnyObject {
    
}

class SCAusweisAuthCardBlockedViewController: UIViewController {

    var presenter : SCAusweisAuthCardBlockedPresenting!
    
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var submitButton: SCCustomButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.presenter.setDisplay(display: self)
    }
    
    @IBAction func submitClicked(_ sender: Any) {
        
         
    }
    
    func setupUI() {
        
        submitButton.customizeAusweisBlueStyle()
        lblHeader.text = "egov_cardblocked_label".localized()
        lblInfo.text = "\("egov_cardblocked_info1".localized())\n\n\("egov_cardblocked_info2".localized())"
        submitButton.setTitle("", for: .normal)
        
        
        lblHeader.adjustsFontForContentSizeCategory = true
        lblHeader.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 16.0, maxSize: nil)

        lblInfo.adjustsFontForContentSizeCategory = true
        lblInfo.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)
        
        submitButton.titleLabel?.adjustsFontForContentSizeCategory = true
        submitButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)
        submitButton.titleLabel?.numberOfLines = 0
        submitButton.titleLabel?.lineBreakMode = .byWordWrapping
    }
}

extension SCAusweisAuthCardBlockedViewController : SCAusweisAuthCardBlockedViewDisplay {
    
}
