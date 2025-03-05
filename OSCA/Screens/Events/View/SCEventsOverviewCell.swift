/*
Created by Michael on 08.10.19.
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

class SCEventsOverviewCell: UITableViewCell {
    
    @IBOutlet weak var eventStatusLabel: UILabelInsets!
    @IBOutlet weak var eventCellDateLabel: UILabel!
    @IBOutlet weak var eventCellTitleLabel: UILabel!
    @IBOutlet weak var eventCellLabel: UILabel!
    @IBOutlet weak var eventCellImageView: UIImageView!
    @IBOutlet weak var reminerImageView: UIImageView!
    @IBOutlet weak var favouriteImageView: UIImageView!
    @IBOutlet weak var eventCellImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventCellImageViewAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventStackBottomConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupAccessibilityIDs()
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        
        self.eventCellDateLabel.accessibilityIdentifier = "lbl_date"
        self.eventCellTitleLabel.accessibilityIdentifier = "lbl_title"
        self.eventCellLabel.accessibilityIdentifier = "lbl_info"
        self.eventCellImageView.accessibilityIdentifier = "img_event"
        self.eventStatusLabel.accessibilityIdentifier = "lbl_status"
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupEventStatusLabel(_ statusColor: UIColor, statusText: String) {
        eventStatusLabel.isHidden = false
        eventStatusLabel.backgroundColor = statusColor
        eventStatusLabel.textColor = .white
        eventStatusLabel.text = statusText
        let bounds: CGRect = eventStatusLabel.bounds
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: ([.bottomLeft, .bottomRight]), cornerRadii: CGSize(width: 5.0, height: 5.0))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        eventStatusLabel.layer.mask = maskLayer
    }
}
