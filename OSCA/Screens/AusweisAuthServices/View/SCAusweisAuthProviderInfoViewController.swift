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

protocol SCAusweisAuthProviderInfoDisplay : SCDisplaying, AnyObject {
    
    func setProvider(_ provider : String)
    func setProviderLink(_ link : String)
    func setIssuer(_ issuer : String)
    func setIssuerLink(_ link : String)
    func setProviderInfo(_ info : String)
    func setValidity(_ validity : String)
    
}

class SCAusweisAuthProviderInfoViewController: UIViewController {

    var presenter : SCAusweisAuthProviderInfoPresenting!

    @IBOutlet weak var providerTitleLabel : UILabel!
    @IBOutlet weak var providerValueLabel : UILabel!
    @IBOutlet weak var providerLinkButton : UIButton!

    @IBOutlet weak var issuerTitleLabel : UILabel!
    @IBOutlet weak var issuerValueLabel : UILabel!
    @IBOutlet weak var issuerLinkButton : UIButton!

    @IBOutlet weak var providerInfoTitleLabel : UILabel!
    @IBOutlet weak var providerInfoValueTextView : UITextView!
    
    @IBOutlet weak var validityTitleLabel : UILabel!
    @IBOutlet weak var validityValueLabel : UILabel!


    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.presenter.setDisplay(display: self)
        self.presenter.viewDidLoad()
    }

    func setupUI() {
        
        providerTitleLabel.text = "egov_certificate_provider".localized()
        issuerTitleLabel.text = "egov_certificate_issuer".localized()
        providerInfoTitleLabel.text = "egov_certificate_providerinfo".localized()
        validityTitleLabel.text = "egov_certificate_validity".localized()
        
        
        providerTitleLabel.adjustsFontForContentSizeCategory = true
        providerTitleLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 16.0, maxSize: nil)

        providerValueLabel.adjustsFontForContentSizeCategory = true
        providerValueLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)

        providerLinkButton.titleLabel?.adjustsFontForContentSizeCategory = true
        providerLinkButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)
        providerLinkButton.titleLabel?.numberOfLines = 0
        providerLinkButton.titleLabel?.lineBreakMode = .byCharWrapping
        
        issuerTitleLabel.adjustsFontForContentSizeCategory = true
        issuerTitleLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 16.0, maxSize: nil)

        issuerValueLabel.adjustsFontForContentSizeCategory = true
        issuerValueLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)

        issuerLinkButton.titleLabel?.adjustsFontForContentSizeCategory = true
        issuerLinkButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)
        issuerLinkButton.titleLabel?.numberOfLines = 0
        issuerLinkButton.titleLabel?.lineBreakMode = .byCharWrapping
        
        providerInfoTitleLabel.adjustsFontForContentSizeCategory = true
        providerInfoTitleLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 16.0, maxSize: nil)

        providerInfoValueTextView.adjustsFontForContentSizeCategory = true
        providerInfoValueTextView.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)

        validityTitleLabel.adjustsFontForContentSizeCategory = true
        validityTitleLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 16.0, maxSize: nil)

        validityValueLabel.adjustsFontForContentSizeCategory = true
        validityValueLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: nil)

    }
    
    @IBAction func providerLinkClicked(_ sender: Any) {
        presenter.onProviderLinkClicked()
    }
    
    @IBAction func issuerLinkClicked(_ sender: Any) {
        presenter.onIssuerLinkClicked()
    }
    
}

extension SCAusweisAuthProviderInfoViewController : SCAusweisAuthProviderInfoDisplay {
    
    func setProvider(_ provider : String){
        self.providerValueLabel.text = provider
    }
    
    func setProviderLink(_ link : String) {
        self.providerLinkButton.setTitle(link, for: .normal)
    }
    
    func setIssuer(_ issuer : String) {
        self.issuerValueLabel.text = issuer
    }
    
    func setIssuerLink(_ link : String) {
        self.issuerLinkButton.setTitle(link, for: .normal)
    }
    
    func setProviderInfo(_ info : String) {
        self.providerInfoValueTextView.text = info
    }
    
    func setValidity(_ validity : String) {
        self.validityValueLabel.text = validity
    }

}
