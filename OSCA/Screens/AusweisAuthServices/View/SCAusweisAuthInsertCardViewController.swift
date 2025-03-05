/*
Created by Bharat Jagtap on 01/03/21.
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

protocol SCAusweisAuthInsertCardDisplay : SCDisplaying, AnyObject {

}

class SCAusweisAuthInsertCardViewController: UIViewController {
    var presenter : SCAusweisAuthInsertCardPresenting!
        
    @IBOutlet weak var lblHoldTheCard: UILabel!
    @IBOutlet weak var lblImageGuideLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupAccessibilityIDs()
        setupAccessibility()
        presenter.setDisplay(display: self)
        presenter.viewDidLoad()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
    }
    
    func setupUI() {
        
        lblHoldTheCard.text = "egov_attach_card_info1".localized()
        lblImageGuideLabel.text = "egov_attach_card_info2".localized()
        
        lblHoldTheCard.adjustsFontForContentSizeCategory = true
        lblHoldTheCard.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)

        lblImageGuideLabel.adjustsFontForContentSizeCategory = true
        lblImageGuideLabel.font = UIFont.SystemFont.italic.forTextStyle(style: .body, size: 16.0, maxSize: nil)

    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){

        lblHoldTheCard.accessibilityIdentifier = "lbl_lHoldTheCard"
        lblImageGuideLabel.accessibilityIdentifier = "lbl_ImageGuideLabel"
    }

    private func setupAccessibility(){
        
        lblHoldTheCard.accessibilityLabel = "egov_attach_card_info1".localized()
        lblHoldTheCard.accessibilityTraits =  .staticText
        lblHoldTheCard.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        lblImageGuideLabel.accessibilityLabel = "egov_attach_card_info2".localized()
        lblImageGuideLabel.accessibilityTraits =  .staticText
        lblImageGuideLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
    }
}

extension SCAusweisAuthInsertCardViewController : SCAusweisAuthInsertCardDisplay {
    
    
}
