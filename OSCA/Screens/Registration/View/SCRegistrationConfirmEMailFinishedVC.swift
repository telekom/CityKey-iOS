/*
Created by Michael on 12.03.19.
Copyright © 2019 Michael. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Copyright © 2019 Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

class SCRegistrationConfirmEMailFinishedVC: UIViewController {

    public var presenter: SCRegistrationConfirmEMailFinishedPresenting!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var finishBtn: SCCustomButton!

    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var topImageHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var successImageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var topImageSymbolView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAccessibilityIDs()
        handleDynamicFontChange()
        
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
   }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.titleLabel.accessibilityIdentifier = "lbl_title"
        self.detailLabel.accessibilityIdentifier = "lbl_detail"

        self.finishBtn.accessibilityIdentifier = "btn_finish"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }
    
    private func handleDynamicFontChange() {
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 18, maxSize: 30)
        
        detailLabel.adjustsFontForContentSizeCategory = true
        detailLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 14, maxSize: 26)
    }
    
    @IBAction func finishBtnWasPressed(_ sender: Any) {
        self.presenter.finishedWasPressed()
       
    }
    
}

extension SCRegistrationConfirmEMailFinishedVC: SCRegistrationConfirmEMailFinishedDisplaying {
    
    func setupNavigationBar(title: String){
        self.navigationItem.title = title
        // remove the Back button
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.topItem?.title = title
        
    }
    
    func hideTopImage() {
        self.topImageHeightConstraint.constant = 0.0
        self.topImageView.isHidden = true
        self.topImageSymbolView.isHidden = true
    }

    func setupUI(titleText: String, detailText: String, btnText: String, topImageSymbol: UIImage){
        self.titleLabel.adaptFontSize()
        self.titleLabel.text = titleText
        
        self.detailLabel.adaptFontSize()
        self.detailLabel.text = detailText
        
        self.finishBtn.customizeBlueStyle()
        self.finishBtn.setTitle(btnText, for: .normal)
        self.finishBtn.titleLabel?.adaptFontSize()
        
        self.topImageSymbolView.image = topImageSymbol

        self.successImageTopConstraint.constant = 40.0
        
        // remove the Back button
        self.view.setNeedsLayout()

    }

    func dismissView(completion: (() -> Void)? = nil) {
        self.dismiss(animated: true, completion: completion)
    }

    func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }

}
