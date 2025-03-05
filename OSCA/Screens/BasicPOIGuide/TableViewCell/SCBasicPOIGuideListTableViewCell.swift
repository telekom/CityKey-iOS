/*
Created by Harshada Deshmukh on 16/03/21.
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

class SCBasicPOIGuideListTableViewCell: UITableViewCell {

    @IBOutlet weak var imageCategory: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var openHoursTxtV: UITextView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var openHoursLbl: UILabel!
    @IBOutlet weak var arrowIcon: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var addressStack: UIStackView!
    @IBOutlet weak var openHoursStack: UIStackView!
    @IBOutlet weak var openHoursHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topSpaceFromAddressConstraint: NSLayoutConstraint!
    @IBOutlet weak var topSpaceFromOpenHrsConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.setupAccessibilityIDs()
        // Initialization code
        if #available(iOS 13.0, *) {
            activityIndicatorView.style = .medium
        } else {
            activityIndicatorView.style = .gray
        }
    }

    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.imageCategory.accessibilityIdentifier = "img_category"
        self.categoryLabel.accessibilityIdentifier = "lbl_select_category"
        self.addressLabel.accessibilityIdentifier = "lbl_address"
        self.openHoursTxtV.accessibilityIdentifier = "lbl_open_hours"
        self.distanceLabel.accessibilityIdentifier = "lbl_distance"
        self.addressLbl.accessibilityIdentifier = "lbl_address_heading"
        self.openHoursLbl.accessibilityIdentifier = "lbl_open_hours_heading"
        self.arrowIcon.accessibilityIdentifier = "lbl_more"
        self.accessibilityIdentifier = "cell"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setup(poi: POIInfo) {
        
        handleDynamicFontChange()
        self.addressLbl.text = LocalizationKeys.SCBasicPOIGuideListMapFilterViewController.poi001AddressLabel.localized()
        self.openHoursLbl.text = LocalizationKeys.SCBasicPOIGuideListMapFilterViewController.poi001OpeningHoursLabel.localized()
        
        self.categoryLabel.attributedText = poi.title.applyHyphenation()
//        self.imageCategory.load(from: image)
        self.imageCategory.image = SCUserDefaultsHelper.setupCategoryIcon(SCUserDefaultsHelper.getPOICategoryGroupIcon() ?? "").maskWithColor(color: kColor_cityColor)

        self.addressLabel.attributedText = poi.address.applyHyphenation()
        
        let attrStringOH =  poi.openHours.htmlAttributedString
        let htmlAttributedStringOH = NSMutableAttributedString(attributedString: attrStringOH!)
        htmlAttributedStringOH.replaceFont(with: self.openHoursTxtV.font!, color: self.openHoursTxtV.textColor!)
        self.openHoursTxtV.attributedText = htmlAttributedStringOH
        self.openHoursTxtV.linkTextAttributes = [.foregroundColor: kColor_cityColor]
        self.openHoursTxtV.textContainerInset = UIEdgeInsets.zero
        self.openHoursTxtV.textContainer.lineFragmentPadding = 0

        self.distanceLabel.text = String(poi.distance) + " km"
        self.openHoursLbl.isHidden = !poi.openHours.isSpaceOrEmpty() ? false : true
        self.addressLbl.isHidden = !poi.address.isSpaceOrEmpty() ? false : true
        self.addressLabel.isHidden = !poi.address.isSpaceOrEmpty() ? false : true

        self.addressStack.isHidden = !poi.address.isSpaceOrEmpty() ? false : true
        self.openHoursStack.isHidden = !poi.openHours.isSpaceOrEmpty() ? false : true
             
        let heightOpenHrsTitle = self.openHoursTxtV.calculateViewHeightWithCurrentWidth()
        openHoursHeightConstraint.constant = !poi.openHours.isSpaceOrEmpty() ?  CGFloat(heightOpenHrsTitle) : 0
        self.topSpaceFromAddressConstraint.constant = !poi.address.isSpaceOrEmpty() ? 15 : 0
        self.topSpaceFromOpenHrsConstraint.constant = !poi.openHours.isSpaceOrEmpty() ? 15 : 0
        self.openHoursTxtV.isUserInteractionEnabled = false

    }
    
    fileprivate func handleDynamicFontChange() {
        categoryLabel.adjustsFontForContentSizeCategory = true
        categoryLabel.font = UIFont.SystemFont.medium.forTextStyle(style: .body, size: 15.0, maxSize: 24.0)
        
        distanceLabel.adjustsFontForContentSizeCategory = true
        distanceLabel.font = UIFont.SystemFont.light.forTextStyle(style: .body, size: 15.0, maxSize: 24.0)
        
        addressLbl.adjustsFontForContentSizeCategory = true
        addressLbl.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 15.0, maxSize: 24.0)
        
        addressLabel.adjustsFontForContentSizeCategory = true
        addressLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 15.0, maxSize: 24.0)
        
        openHoursLbl.adjustsFontForContentSizeCategory = true
        openHoursLbl.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 15.0, maxSize: 24.0)
        
        openHoursTxtV.adjustsFontForContentSizeCategory = true
        openHoursTxtV.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 15.0, maxSize: 24.0)
    }

    func setupAccessibilty(_ index: Int, count: Int){
        
        // set accessibilty information
        self.imageCategory.accessibilityElementsHidden = true
        self.categoryLabel.accessibilityElementsHidden = true
        self.addressLabel.accessibilityElementsHidden = true
        self.openHoursTxtV.accessibilityElementsHidden = true
        self.distanceLabel.accessibilityElementsHidden = true
        self.addressLbl.accessibilityElementsHidden = true
        self.openHoursLbl.accessibilityElementsHidden = true
        self.arrowIcon.accessibilityElementsHidden = true
        self.activityIndicatorView.accessibilityElementsHidden = true
        self.addressStack.accessibilityElementsHidden = true
        self.openHoursStack.accessibilityElementsHidden = true
                    
        let accItemString = String(format:LocalizationKeys.SCBasicPOIGuideListTableViewCell.accessibilityTableSelectedCell.localized().replaceStringFormatter(), String(index + 1), String(count))
        self.accessibilityTraits = .staticText
        self.accessibilityHint = LocalizationKeys.SCBasicPOIGuideListTableViewCell.accessibilityCellDblClickHint.localized()
        let poiInfo = accItemString
        let category = (self.categoryLabel.text ?? "")
        let address = !self.addressLabel.text!.isSpaceOrEmpty() ? (self.addressLbl.text ?? "") + ", " + (self.addressLabel.text ?? "") : ""
        let openHours = !self.openHoursTxtV.text!.isSpaceOrEmpty() ? (self.openHoursLbl.text ?? "") + ", " + (self.openHoursTxtV.text ?? "") : ""
        let distance = (self.distanceLabel.text ?? "")
        self.accessibilityLabel = poiInfo + ", " + category + ", " + address + ", " + openHours + ", " + distance
        self.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.isAccessibilityElement = true
    }
}
