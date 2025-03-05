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

class SCEditProfileOverviewTVCTableViewController: UITableViewController {

    public var presenter: SCEditProfileOverviewPresenting!

    @IBOutlet weak var eMailChangeTopLbl: UILabel!
    @IBOutlet weak var eMailChangeTxtField: UITextField!
    @IBOutlet weak var pwdChangeTopLbl: UILabel!
    @IBOutlet weak var pwdChangeTxtField: UITextField!
    @IBOutlet weak var deleteAccountTextField: UITextField!
    @IBOutlet weak var deleteAccountTopLabel: UILabel!
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
        self.eMailChangeTopLbl.accessibilityIdentifier = "lbl_email_change"
        self.eMailChangeTxtField.accessibilityIdentifier = "txtfld_email_change"
        self.pwdChangeTopLbl.accessibilityIdentifier = "lbl_change_password"
        self.pwdChangeTxtField.accessibilityIdentifier = "txtfld_change_password"
//        self.deleteAccountTextField.accessibilityIdentifier = "txtfld_delete_account"
        self.deleteAccountTopLabel.accessibilityIdentifier = "lbl_delete_account"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }
    
    private func setupAccessibility(){
        self.closeBtn.accessibilityTraits = .button
        self.closeBtn.accessibilityLabel = "accessibility_btn_close".localized()
        self.closeBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        // Dynamic font
        eMailChangeTopLbl.adjustsFontForContentSizeCategory = true
        eMailChangeTopLbl.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: 25)
        eMailChangeTxtField.adjustsFontForContentSizeCategory = true
        eMailChangeTxtField.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 20, maxSize: 20)
        
        pwdChangeTopLbl.adjustsFontForContentSizeCategory = true
        pwdChangeTopLbl.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: 25)
        pwdChangeTxtField.adjustsFontForContentSizeCategory = true
        pwdChangeTxtField.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 20, maxSize: 25)
        
        deleteAccountTopLabel.adjustsFontForContentSizeCategory = true
        deleteAccountTopLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: 25)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.presenter.viewWillAppear()
        
    }

    @IBAction func closeBtnWasPressed(_ sender: Any) {
        self.presenter.closeButtonWasPressed()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // FOR MONHEIM WE WIl ONLY SHOW 2 ITEMS, THE DELETE ACCOUNT IS MISSING
//        return 2
        return 3
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
            
        case 0:
            self.presenter.editEMailWasPressed()
            break
        case 1:
            self.presenter.editPWDWasPressed()
            break
        case 2:
            self.presenter.deleteAccountWasPressed()
            break
        default:
            self.presenter.editEMailWasPressed()
            break
        }
    }

}

extension SCEditProfileOverviewTVCTableViewController: SCEditProfileOverviewDisplaying {
    
    func setupNavigationBar(title: String){
        self.navigationItem.title = title
        self.navigationItem.backButtonTitle = ""
    }
    
    func setupUI(email : String){
        self.eMailChangeTopLbl.text = "p_002_profile_settings_label_email".localized()
        self.pwdChangeTopLbl.text = "p_002_profile_settings_label_password".localized()
        self.deleteAccountTopLabel.text = "p_002_profile_settings_label_delete_account".localized()
        self.eMailChangeTxtField.placeholder = "p_002_profile_settings_label_email".localized()
        self.pwdChangeTxtField.placeholder = "p_002_profile_settings_label_password".localized()
        self.eMailChangeTxtField.text = email
        self.pwdChangeTxtField.text = "p_002_profile_settings_label_password".localized()
//        self.deleteAccountTextField.text = "d_001_delete_account_info_info2".localized()
    }

    func push(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func dismiss(completion: (() -> Void)?) {
        self.dismiss(animated: true, completion: completion)
    }

}

