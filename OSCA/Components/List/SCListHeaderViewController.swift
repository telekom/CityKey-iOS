/*
Created by Michael on 13.10.18.
Copyright © 2018 Michael. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Copyright © 2018 Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

protocol SCListHeaderViewControllerDelegate : NSObjectProtocol
{
    func didPressMoreBtn()
}

class SCListHeaderViewController: UIViewController {

    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet var listHeaderView: UIView!
    @IBOutlet weak var listHeaderLabel: UILabel!
    weak var delegate : SCListHeaderViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.handleDynamicTypeChange()

        NotificationCenter.default.addObserver(self, selector: #selector(handleDynamicTypeChange), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }
    
    @objc private func handleDynamicTypeChange() {
        // Dynamic font
        self.listHeaderLabel.adjustsFontForContentSizeCategory = true
        self.listHeaderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 18, maxSize: 27)
        self.moreBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        self.moreBtn.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 14, maxSize: 25)
    }

    func customize(color : UIColor) {
        self.listHeaderView.backgroundColor = color
    }
    
    
    func update(headerText : String, accessibilityID : String) {

        //adaptive Font Size
        self.listHeaderLabel.adaptFontSize()
        
        self.listHeaderLabel.text = headerText
        self.listHeaderLabel.accessibilityIdentifier = accessibilityID
        self.listHeaderLabel.accessibilityTraits = .header
        self.listHeaderLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.moreBtn.accessibilityIdentifier = "btn_more_" + accessibilityID
        self.moreBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }

    func update(moreBtnText : String, visible: Bool) {
        self.moreBtn.titleLabel?.adaptFontSize()

        self.moreBtn.setTitle(moreBtnText,for: .normal)
        self.moreBtn.isHidden = !visible
    }

    func isMoreBtnVisible(_ visible : Bool) {
        self.moreBtn.isHidden = !visible
    }

    
    // MARK: - private methods
     @IBAction func moreBtnWasPressed(_ sender: Any) {
        self.delegate?.didPressMoreBtn()
     }

}
