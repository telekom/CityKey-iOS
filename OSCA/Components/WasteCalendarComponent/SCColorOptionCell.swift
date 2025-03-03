/*
Created by A118572539 on 06/01/22.
Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, A118572539
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

class SCColorOptionCell: UITableViewCell {
    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var colorTitleLabel: UILabel!

    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var separator: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        colorButton.setTitle("", for: .normal)
        
        //adaptive Font Size
        self.colorTitleLabel.adaptFontSize()
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        separator.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
    }
    
    private func setupAccessibilityIDs() {
        self.colorTitleLabel.accessibilityIdentifier = "lbl_ColorName"
        self.rightImageView.accessibilityIdentifier = "img_rightSelected"
        self.accessibilityIdentifier = "cell"
    }
    
    private func setupAccessibility() {
        self.colorTitleLabel.accessibilityTraits = .staticText
        self.colorTitleLabel.accessibilityLabel = colorTitleLabel.text
        self.colorTitleLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
