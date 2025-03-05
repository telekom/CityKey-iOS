/*
Created by Harshada Deshmukh on 26/02/21.
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Harshada Deshmukh
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

class SCBasicPOIGuideCategoryTableViewHeaderCell: UITableViewCell {

    @IBOutlet weak var categoryGroupLabel: UILabel!
    @IBOutlet weak var imageCategory: UIImageView!
        
    override func awakeFromNib() {
        super.awakeFromNib()

        //adaptive Font Size
        self.categoryGroupLabel.adaptFontSize()
        self.setupAccessibilityIDs()
    }

    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.categoryGroupLabel.accessibilityIdentifier = "lbl_select_category_group"
        self.imageCategory.accessibilityIdentifier = "img_city"
        self.accessibilityIdentifier = "cell"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func set(title: String, image: SCImageURL?) {
        self.categoryGroupLabel.text = title
        self.imageCategory.load(from: image)
    }

}


