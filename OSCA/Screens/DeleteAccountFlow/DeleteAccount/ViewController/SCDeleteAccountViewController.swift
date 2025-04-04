/*
Created by Alexander Lichius on 08.08.19.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Alexander Lichius
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

protocol SCDeleteAccountDisplaying {
    func push(viewController: UIViewController)
    func setupNavTitle(with title: String)
    func setupTitleLabel(with title: String)
    func setupDescriptionLabel(with text: String)
    func setupDeleteAccountButton(with title: String)
    func dismiss(completion: (() -> Void)?)

}

class SCDeleteAccountViewController: UIViewController {
    
    @IBOutlet weak var deleteAccountButton: SCCustomButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: SCTopAlignLabel!
    @IBOutlet weak var closeBtn: UIBarButtonItem!

    

    var presenter: SCDeleteAccountPresenting!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAccessibilityIDs()
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
        setupDynamicFont()
    }
    
    private func setupDynamicFont() {
        titleLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 17, maxSize: nil)
        descriptionLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 17, maxSize: nil)
        deleteAccountButton.titleLabel?.adjustsFontForContentSizeCategory = true
        deleteAccountButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 18, maxSize: 30)
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.deleteAccountButton.accessibilityIdentifier = "btn_delete_account"
        self.titleLabel.accessibilityIdentifier = "lbl_title"
        self.descriptionLabel.accessibilityIdentifier = "lbl_description"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func DeleteAccountButtonWasPressed(_ sender: Any) {
        self.presenter.deleteAccountButtonWasPressed()
    }
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        self.presenter.closeButtonWasPressed()
    }
}
