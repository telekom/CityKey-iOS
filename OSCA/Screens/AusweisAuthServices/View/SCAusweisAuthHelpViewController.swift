/*
Created by Bharat Jagtap on 16/03/21.
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

protocol SCAusweisAuthHelpViewDisplay : SCDisplaying, AnyObject {
    
}

class SCAusweisAuthHelpViewController: UIViewController {
    
    var presenter : SCAusweisAuthHelpPresenting!
    
    @IBOutlet weak var q1TitleLabel : UILabel!
    @IBOutlet weak var q1InfoLabel : UILabel!
    @IBOutlet weak var q1LinkButton : UIButton!

    @IBOutlet weak var q2TitleLabel : UILabel!
    @IBOutlet weak var q2InfoLabel : UILabel!

    @IBOutlet weak var q3TitleLabel : UILabel!
    @IBOutlet weak var q3InfoLabel : UILabel!
    @IBOutlet weak var q3LinkButton : UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.presenter.setDisplay(display: self)
        self.presenter.viewDidLoad()
    }
    
    func setupUI() {
        
        q1TitleLabel.text = "egov_help_label1".localized()
        q1InfoLabel.text = "egov_help_info1".localized()
        q1LinkButton.setTitle("egov_help_ausweissapp_link".localized(), for: .normal)
        q1LinkButton.tintColor = UIColor.clear

        q2TitleLabel.text = "egov_help_label2".localized()
        q2InfoLabel.text = "egov_help_info2".localized()
        
        q3TitleLabel.text = "egov_help_label3".localized()
        q3InfoLabel.text = "egov_help_info3".localized()
        q3LinkButton.setTitle("egov_help_aussweissapp_help_link".localized(), for: .normal)
        q3LinkButton.tintColor = UIColor.clear
        
        q1TitleLabel.adjustsFontForContentSizeCategory = true
        q1TitleLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 16.0, maxSize: nil)

        q1InfoLabel.adjustsFontForContentSizeCategory = true
        q1InfoLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)
        
        q1LinkButton.titleLabel?.adjustsFontForContentSizeCategory = true
        q1LinkButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: 30.0)
        q1LinkButton.titleLabel?.numberOfLines = 0
        q1LinkButton.titleLabel?.lineBreakMode = .byWordWrapping
        
        q2TitleLabel.adjustsFontForContentSizeCategory = true
        q2TitleLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 16.0, maxSize: nil)

        q2InfoLabel.adjustsFontForContentSizeCategory = true
        q2InfoLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)
        
        q3TitleLabel.adjustsFontForContentSizeCategory = true
        q3TitleLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 16.0, maxSize: nil)

        q3InfoLabel.adjustsFontForContentSizeCategory = true
        q3InfoLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)
        
        q3LinkButton.titleLabel?.adjustsFontForContentSizeCategory = true
        q3LinkButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: 30.0)
        q3LinkButton.titleLabel?.numberOfLines = 0
        q3LinkButton.titleLabel?.lineBreakMode = .byWordWrapping

    }
    
    func setupAccessibilityIDs() {
        
    }
    
    func setupAccessibility() {
        
        
    }
    
    @IBAction func downloadAusweisAppClicked(_ sender: Any) {
    
        self.presenter.onDownloadAusweisAppClick()
    }
    
    @IBAction func callAusweisAppHelpClicked(_ sender: Any) {
        
        self.presenter.onCallAusweisHelpClick()
    }
}

extension SCAusweisAuthHelpViewController : SCAusweisAuthHelpViewDisplay {
    
    
}
