/*
Created by Michael on 06.03.19.
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

class SCRegistrationPWDCheckVC: UIViewController {

    
    @IBOutlet weak var pwdCheckTopLabel: UILabel!
    @IBOutlet weak var pwdCheckDetailLabel: SCTopAlignLabel!
    @IBOutlet weak var pwdCheckBar: UIView!
    @IBOutlet weak var pwdCheckDetailLabelHeight: NSLayoutConstraint!
    
    let progressBar = UIView()
    var progressBarMaxWidth:CGFloat {
        return self.pwdCheckBar.bounds.size.width - 2 * self.pwdCheckBar.layer.borderWidth
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        
        self.pwdCheckTopLabel.adaptFontSize()
        self.pwdCheckDetailLabel.adaptFontSize()

        self.pwdCheckTopLabel.text = "r_001_registration_p_005_profile_password_strength_label".localized()
        self.refreshWith(charCount : 0, minCharReached: false, symbolAvailable: false, digitAvailable: false)
        
        self.pwdCheckBar.layer.borderWidth = 1.0
        self.pwdCheckBar.layer.borderColor = UIColor(named: "CLR_BORDER_SILVERGRAY")!.cgColor

        self.pwdCheckBar.addSubview(progressBar)
        
        self.progressBar.frame = CGRect(x: self.pwdCheckBar.layer.borderWidth, y: self.pwdCheckBar.layer.borderWidth, width: 0.0, height: pwdCheckBar.bounds.size.height - 2 * self.pwdCheckBar.layer.borderWidth)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.pwdCheckDetailLabelHeight.constant = self.pwdCheckDetailLabel.intrinsicContentSize.height
        self.view.setNeedsLayout()
        super.viewDidAppear(animated)
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.pwdCheckTopLabel.accessibilityIdentifier = "lbl_top"
        self.pwdCheckDetailLabel.accessibilityIdentifier = "lbl_detail"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"

    }
    
    private func setupAccessibility(){
        self.pwdCheckTopLabel.accessibilityLabel = self.pwdCheckTopLabel.text
        self.pwdCheckTopLabel.accessibilityTraits = .staticText
        self.pwdCheckTopLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
//        self.pwdCheckDetailLabel.accessibilityLabel = self.pwdCheckDetailLabel.text
//        self.pwdCheckDetailLabel.accessibilityTraits = .staticText
//        self.pwdCheckDetailLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }

    func refreshWith(charCount: Int,  minCharReached : Bool, symbolAvailable : Bool, digitAvailable: Bool, showRedLineAnyway :Bool = false) {
        let hintPasswordStrength = "r_001_registration_hint_password_strength".localized().replacingOccurrences(of: "%s", with: "")
        let checktxt = hintPasswordStrength + " " + checkText()
        let attrString = NSMutableAttributedString(string: checktxt)
        self.pwdCheckDetailLabel.attributedText = formatCheckText(checkText: attrString, minCharReached: minCharReached, symbolAvailable: symbolAvailable, digitAvailable: digitAvailable)
        self.pwdCheckDetailLabelHeight.constant = self.pwdCheckDetailLabel.intrinsicContentSize.height
        
        if charCount > 0 {
            formatProgressBar(charcount: charCount, minCharReached: minCharReached, symbolAvailable: symbolAvailable, digitAvailable: digitAvailable)
        } else {
            self.progressBar.frame.size.width =  0.0
        }
        if showRedLineAnyway {
            self.progressBar.backgroundColor = UIColor(named: "CLR_LABEL_TEXT_RED")!
        }
        self.view.setNeedsLayout()
    }
    
    private func checkText() -> String {
        return "r_001_registration_p_005_profile_password_strength_hint_min_8_chars".localized() + ", " + "r_001_registration_p_005_profile_password_strength_error_min_1_symbol".localized() + ", " + "r_001_registration_p_005_profile_password_strength_error_min_1_digit".localized()
    }
    
    private func formatCheckText(checkText: NSMutableAttributedString, minCharReached: Bool, symbolAvailable: Bool, digitAvailable: Bool) -> NSMutableAttributedString {
        if minCharReached {
            _ = checkText.setAsStrikeThrough(textToFind:"r_001_registration_p_005_profile_password_strength_hint_min_8_chars".localized())
        }
        
        if symbolAvailable {
            _ = checkText.setAsStrikeThrough(textToFind:"r_001_registration_p_005_profile_password_strength_error_min_1_symbol".localized())
        }
        
        if digitAvailable {
            _ = checkText.setAsStrikeThrough(textToFind: "r_001_registration_p_005_profile_password_strength_error_min_1_digit".localized())
        }
        
        return checkText
    }
    
    private func formatProgressBar(charcount: Int, minCharReached: Bool, symbolAvailable: Bool, digitAvailable: Bool) {
        var restrictionMet: Int = 0
        if charcount > 0 {
            restrictionMet += 1
        }
        
        if minCharReached {
            restrictionMet += 1
        }
        
        if symbolAvailable {
            restrictionMet += 1
        }
        
        if digitAvailable {
            restrictionMet += 1
        }
        
        self.progressBar.frame.size.width =  floor( CGFloat(restrictionMet) * self.progressBarMaxWidth / 4.0 )
        if restrictionMet == 4 {
            self.progressBar.backgroundColor = UIColor(named: "CLR_LABEL_TEXT_GREEN")!
        } else {
            self.progressBar.backgroundColor = UIColor(named: "CLR_LABEL_TEXT_RED")!
        }
        
        
        
    }
}
