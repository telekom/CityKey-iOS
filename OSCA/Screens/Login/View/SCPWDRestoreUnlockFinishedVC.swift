/*
Created by Michael on 04.04.19.
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



class SCPWDRestoreUnlockFinishedVC: UIViewController {

    public var presenter:   SCPWDRestoreUnlockFinishedPresenting!

    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var additionalLabel: SCTopAlignLabel!
    @IBOutlet weak var resentLabel: UILabel!
    @IBOutlet weak var resentBtn: UIButton!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAccessibilityIDs()
        
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()

    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.topImageView.accessibilityIdentifier = "img_top"
        self.notificationLabel.accessibilityIdentifier = "lbl_notification"
        self.titleLabel.accessibilityIdentifier = "lbl_title"
        self.detailLabel.accessibilityIdentifier = "lbl_detail"
        self.additionalLabel.accessibilityIdentifier = "lbl_additional"
        self.resentBtn.accessibilityIdentifier = "btn_resent"
        self.resentLabel.accessibilityIdentifier = "lbl_resent"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }

    private func attributedSuccessString(for email: String) -> NSAttributedString{
        
        let titletext = "f_001_forgot_password_info_verify_mail".localized().replacingOccurrences(of: "%s", with: email)
            
        let attributedString = NSMutableAttributedString(string: titletext)
        _ = attributedString.setAsBoldFont(textToFind: email, fontSize: self.titleLabel.font.pointSize)
            
        return attributedString
    }

    @IBAction func resentBtnWasPressed(_ sender: Any) {
        self.presenter.resendWasPressed()
    }
    
    
}

extension SCPWDRestoreUnlockFinishedVC: SCPWDRestoreUnlockFinishedDisplaying {
    func hideResentButton(hide: Bool) {
        self.resentBtn.isHidden = hide
        self.resentLabel.isHidden = hide
    }
    
    
    func displayResendFinished(){
        self.notificationView.isHidden = false
        self.titleTopConstraint.constant = 60.0
        self.view.setNeedsLayout()
    }
    
    func setupUI(with email: String) {
        self.notificationLabel.adaptFontSize()
        self.notificationLabel.text = "f_001_forgot_password_info_sent_link".localized()
        self.titleLabel.adaptFontSize()
        self.titleLabel.attributedText = self.attributedSuccessString(for: email)
        self.detailLabel.adaptFontSize()
        self.detailLabel.text = "f_001_forgot_password_info_follow_instructions".localized()

        self.additionalLabel.adaptFontSize()
        self.additionalLabel.text = "f_001_confirmation_info_only_use_once".localized()

        self.resentLabel.adaptFontSize()
        self.resentLabel.text = "f_001_forgot_password_info_not_received".localized()
        self.resentBtn.setTitle(" " + "f_001_forgot_password_btn_resend_mail".localized(), for: .normal)
        self.resentBtn.titleLabel?.adaptFontSize()
        self.resentBtn.setImage(UIImage(named: "action_resend_email")?.maskWithColor(color: UIColor(named: "CLR_OSCA_BLUE")!), for: .normal)
        
        self.notificationView.isHidden = true
        
        self.titleTopConstraint.constant = 40.0
        self.view.setNeedsLayout()
        // Do any additional setup after loading the view.
    }

}


