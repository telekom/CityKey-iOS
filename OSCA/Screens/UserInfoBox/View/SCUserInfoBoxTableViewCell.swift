/*
Created by Michael on 06.11.18.
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

class SCUserInfoBoxTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var attachementImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var headlineLabel: SCTopAlignLabel!
    @IBOutlet weak var descriptionLabel: SCTopAlignLabel!
    
    @IBOutlet weak var infoReadView: UIView!

    var contentID: String?
    var infoWasRead: Bool = false {
        didSet {
            if infoWasRead {
                self.infoReadView.backgroundColor = UIColor(named: "CLR_BCKGRND")!
            } else {
                self.infoReadView.backgroundColor = kColor_cityColor
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.categoryTitleLabel.adaptFontSize()
        self.dateLabel.adaptFontSize()
        self.headlineLabel.adaptFontSize()
        self.descriptionLabel.adaptFontSize()
        
        self.setupAccessibilityIDs()
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.categoryTitleLabel.accessibilityIdentifier = "lbl_category"
        self.dateLabel.accessibilityIdentifier = "lbl_date"
        self.headlineLabel.accessibilityIdentifier = "lbl_headline"
        self.descriptionLabel.accessibilityIdentifier = "lbl_description"
        self.categoryImageView.accessibilityIdentifier = "img_category"
        self.attachementImageView.accessibilityIdentifier = "img_attach"
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                self.attachementImageView.image = self.attachementImageView.image?.maskWithColor(color: kColor_cityColor)
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(_for item: SCUserInfoBoxMessageItem) {
        categoryTitleLabel.adjustsFontForContentSizeCategory = true
        categoryTitleLabel.font = UIFont.SystemFont.medium.forTextStyle(style: .body, size: 12, maxSize: nil)
        
        dateLabel.adjustsFontForContentSizeCategory = true
        dateLabel.font = UIFont.SystemFont.medium.forTextStyle(style: .body, size: 13, maxSize: 26)
        
        headlineLabel.adjustsFontForContentSizeCategory = true
        headlineLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 15, maxSize: nil)
        
        descriptionLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 14, maxSize: nil)
        
        if let iconUrl = item.icon {
            self.categoryImageView.load(from: SCImageURL(urlString: iconUrl, persistence: false))
        } else {
            self.categoryImageView.image = nil
        }

        if (item.attachmentCount > 0) {
            self.attachementImageView.isHidden = false
            self.attachementImageView.image = self.attachementImageView.image?.maskWithColor(color: kColor_cityColor)
        } else {
            self.attachementImageView.isHidden = true
        }

        self.categoryTitleLabel.text = item.category
        self.dateLabel.text =  infoBoxDateStringFromCreationDate(date: item.creationDate)
        self.headlineLabel.text = item.headline
        self.descriptionLabel.attributedText = item.description.applyHyphenation()
        self.infoWasRead = item.isRead
    }

}
