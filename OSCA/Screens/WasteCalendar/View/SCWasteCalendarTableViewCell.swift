/*
Created by Michael on 27.08.20.
Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

class SCWasteCalendarTableViewCell: UITableViewCell {

    @IBOutlet weak var wasteImageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var reminderImageView: UIImageView!
    @IBOutlet weak var arrowImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.title.adaptFontSize()
        self.contentView.backgroundColor = UIColor.clear
        //self.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        self.accessoryType = UITableViewCell.AccessoryType.none
    }

    func set(wasteType: String, symbolColor: UIColor, isReminderSet: Bool) {
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .dark && symbolColor.hexString == "1A171B" {
                self.wasteImageView.image = UIImage(named: "icon-yellow-trash")!.maskWithColor(color: symbolColor.lighter() ?? .white)
            } else {
                self.wasteImageView.image = UIImage(named: "icon-yellow-trash")!.maskWithColor(color: symbolColor)
            }
        } else {
            self.wasteImageView.image = UIImage(named: "icon-yellow-trash")!.maskWithColor(color: symbolColor)
        }
        self.title.text = wasteType
        reminderImageView.isHidden = !isReminderSet
        reminderImageView.image = UIImage(named: "activated")!.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!)
        self.title.adjustsFontForContentSizeCategory = true
        self.title.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 17, maxSize: nil)

    }

}
