/*
Created by Alexander Lichius on 24.09.19.
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

enum Month: String {
    case Monday
}

class SCDateBox: UIView {
    
    @IBOutlet weak var dayNameMonthLabel: UILabel!
    @IBOutlet weak var dayNumberLabel: UILabel!
    @IBOutlet weak var leftColumn: UIView!
    @IBOutlet weak var dashColumn: UIView!
    @IBOutlet weak var rightColumn: UIView!
    @IBOutlet weak var startDateDayLabel: UILabel!
    @IBOutlet weak var startDateNumberLabel: UILabel!
    @IBOutlet weak var startDateMonthLabel: UILabel!
    @IBOutlet weak var endDateDayLabel: UILabel!
    @IBOutlet weak var endDateNumberLabel: UILabel!
    @IBOutlet weak var endDateMonthLabel: UILabel!
    
    var startDate : Date?
    var endDate : Date?

    // This prevents a color change when the cell gets selected. A cell will change also all backgroundColors of the subviews
    override var backgroundColor: UIColor? {
        didSet {
            if backgroundColor != nil && backgroundColor!.cgColor.alpha == 0 {
                backgroundColor = oldValue
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupAccessibility()
        handleDynamicTypeChange()
    }
    
    
    private func setupAccessibility(){
        self.dayNameMonthLabel.accessibilityElementsHidden = true
        self.dayNumberLabel.accessibilityElementsHidden = true
        self.startDateDayLabel.accessibilityElementsHidden = true
        self.startDateNumberLabel.accessibilityElementsHidden = true
        self.startDateMonthLabel.accessibilityElementsHidden = true
        self.endDateDayLabel.accessibilityElementsHidden = true
        self.endDateNumberLabel.accessibilityElementsHidden = true
        self.endDateMonthLabel.accessibilityElementsHidden = true
    }

    func getAccessibilityContent() -> String{
        
        guard let startDate = self.startDate else {
            return ""
        }
        
        var content = accessibilityConformStringFromDate(date: startDate)
        
        if endDate != nil {
            content +=  "accessibility_label_date_until".localized() + ", " + accessibilityConformStringFromDate(date: endDate!)
        }
        
        return content
    }

    func configure(_with date: Date) {
        self.hideColumns(hide: true)
        self.hideDateLabels(hide: false)
        self.layer.cornerRadius = 4.0
        self.backgroundColor = UIColor(named: "CLR_OSCA_BLUE")!
        let calendarDate = Calendar.current.dateComponents([.day], from: date)
        dayNumberLabel.attributedText = String(calendarDate.day!).applyHyphenation()
        var dayNameMonthText = getDayName(_for: date)
        dayNameMonthText.append(", ")
        dayNameMonthText.append(getMonthName(_for: date))
        dayNameMonthLabel.attributedText = dayNameMonthText.applyHyphenation()
        dayNumberLabel.textAlignment = .center
        dayNameMonthLabel.textAlignment = .center
        self.startDate = date
        self.endDate = nil
    }
    
    func configure(_with startDate: Date, endDate: Date) {
        self.hideDateLabels(hide: true)
        self.hideColumns(hide: false)
        self.layer.cornerRadius = 4.0
        self.backgroundColor = UIColor(named: "CLR_OSCA_BLUE")!
        let startCalendarDate = Calendar.current.dateComponents([.day], from: startDate)
        let endCalendarDate = Calendar.current.dateComponents([.day], from: endDate)
        self.startDateNumberLabel.attributedText = String(startCalendarDate.day!).applyHyphenation()
        self.endDateNumberLabel.attributedText = String(endCalendarDate.day!).applyHyphenation()
        self.startDateDayLabel.text = getDayName(_for: startDate)
        self.endDateDayLabel.text = getDayName(_for: endDate)
        self.startDateMonthLabel.text = getMonthName(_for: startDate)
        self.endDateMonthLabel.text = getMonthName(_for: endDate)
        self.startDate = startDate
        self.endDate = endDate
    }
    
    func hideColumns(hide: Bool) {
        self.dashColumn.isHidden = hide
        self.leftColumn.isHidden = hide
        self.rightColumn.isHidden = hide
    }
    
    func hideDateLabels(hide: Bool) {
        self.dayNameMonthLabel.isHidden = hide
        self.dayNumberLabel.isHidden = hide
    }
    
    @objc func handleDynamicTypeChange() {
        // Dynamic font
        
        dayNumberLabel.adjustsFontForContentSizeCategory = true
        dayNumberLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 18, maxSize: 25)
        dayNameMonthLabel.adjustsFontForContentSizeCategory = true
        dayNameMonthLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 10, maxSize: 20)
        startDateNumberLabel.adjustsFontForContentSizeCategory = true
        startDateNumberLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 11, maxSize: 15)
        endDateNumberLabel.adjustsFontForContentSizeCategory = true
        endDateNumberLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 11, maxSize: 15)
        startDateDayLabel.adjustsFontForContentSizeCategory = true
        startDateDayLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 10, maxSize: 13)
        endDateDayLabel.adjustsFontForContentSizeCategory = true
        endDateDayLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 10, maxSize: 13)
        startDateMonthLabel.adjustsFontForContentSizeCategory = true
        startDateMonthLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 10, maxSize: 13)
        endDateMonthLabel.adjustsFontForContentSizeCategory = true
        endDateMonthLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 10, maxSize: 13)
            
        dayNumberLabel.numberOfLines = 0
        dayNameMonthLabel.numberOfLines = 0
        startDateNumberLabel.numberOfLines = 0
        endDateNumberLabel.numberOfLines = 0
        startDateDayLabel.numberOfLines = 0
        endDateDayLabel.numberOfLines = 0
        startDateMonthLabel.numberOfLines = 0
        endDateMonthLabel.numberOfLines = 0
    }

}
