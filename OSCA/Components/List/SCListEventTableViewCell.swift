/*
Created by Alexander Lichius on 23.09.19.
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
enum EventStatus : String {
    case cancelled = "CANCELLED"
    case postponed = "POSTPONED"
    case soldout = "SOLDOUT"
    case available = "AVAILABLE"
}

class SCListEventTableViewCell: UITableViewCell {

    @IBOutlet weak var eventStatusLabel: UILabelInsets!
    @IBOutlet weak var reminderIcon: UIImageView!
    @IBOutlet weak var favouriteIcon: UIImageView!
    @IBOutlet weak var dateBoxView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var iconStackYConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventStackBottomConstraint: NSLayoutConstraint!

    var model: SCModelEvent? {
        didSet {
            self.configure(model!)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupAccessibility()
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupAccessibility(){
        self.locationLabel.accessibilityElementsHidden = true
        self.eventNameLabel.accessibilityElementsHidden = true
    }

    func configure(_ model: SCModelEvent) {
        locationLabel.attributedText = model.locationName.applyHyphenation()
        locationLabel.lineBreakMode = .byTruncatingTail
        locationLabel.isHidden = !self.locationLabel.text!.isEmpty ? false : true
        self.iconStackYConstraint.isActive = !self.locationLabel.text!.isEmpty ? false : true
        configureCommonEvents(model)
    }
    
    private func configureCommonEvents(_ model: SCModelEvent){
        let strikeThroughText = NSMutableAttributedString(string: model.title)
        eventStatusLabel.isHidden = false
        eventStatusLabel.layer.masksToBounds = true
        eventStatusLabel.layer.cornerRadius = 5.0
        locationLabel.autoresizingMask = [.flexibleWidth]
        
        let status = EventStatus(rawValue: model.status?.uppercased() ?? "AVAILABLE")
        switch status{
        
        case .cancelled :
            strikeThroughText.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, strikeThroughText.length))
            eventNameLabel.attributedText = strikeThroughText
            eventStatusLabel.backgroundColor = UIColor.appointmentRejected
            eventStatusLabel.text = LocalizationKeys.SCEventsOverviewTVC.e007CancelledEvents.localized()
        
        case .postponed :
            eventNameLabel.attributedText = strikeThroughText
            eventStatusLabel.backgroundColor = UIColor.postponeEventStatus
            eventStatusLabel.text = LocalizationKeys.SCEventsOverviewTVC.e007EventsNewDateLabel.localized()
        
        case .soldout :
            eventNameLabel.attributedText = strikeThroughText
            eventStatusLabel.backgroundColor = UIColor.appointmentRejected
            eventStatusLabel.text = LocalizationKeys.SCEventsOverviewTVC.e007EventsSoldOutLabel.localized()
        
        default:
            eventNameLabel.attributedText = model.title.applyHyphenation()
            eventStatusLabel.isHidden = true
        }
    }
    
    
    func configureReminder(active: Bool) {
        self.reminderIcon.isHidden = !active
    }
    
    func configureFavorite(active: Bool, customizeColor : UIColor) {
        self.favouriteIcon.isHidden = !active
        let image = self.favouriteIcon.image?.maskWithColor(color: customizeColor)
        self.favouriteIcon.image = image
    }

}

class UILabelInsets: UILabel {

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        super.drawText(in: rect.inset(by: insets))
    }
}
