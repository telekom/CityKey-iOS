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

protocol SCMarketplaceOverviewTableViewCellDelegate : NSObjectProtocol
{
    func favoriteStateShouldChange(for contentID : String?, newFavSelected: Bool, cell: SCMarketplaceOverviewTableViewCell)
    func showLoginNeededNotificationScreen()
}

class SCMarketplaceOverviewTableViewCell: UITableViewCell {

    @IBOutlet weak var marketplaceCellTitleLabel: UILabel!
    @IBOutlet weak var marketplaceCellLabel: UILabel!
    @IBOutlet weak var marketplaceCellImageView: UIImageView!
    @IBOutlet weak var marketplaceCellImageBackView: UIView!
    @IBOutlet weak var marketplaceFavBtn: UIButton!
    @IBOutlet weak var lockImageView: UIImageView!
    @IBOutlet weak var ribbonImageView: UIImageView!
    @IBOutlet weak var ribbonLabel: UILabel!
    
    var contentID: String?
    var favSelected: Bool = false {
        didSet {
            if favSelected {
                let image = UIImage(named: "icon_fav2_active")?.maskWithColor(color: UIColor(named: "CLR_LABEL_TEXT_WHITE")!)
                self.marketplaceFavBtn.setImage(image , for: .normal)
            } else {
                let image = UIImage(named: "icon_fav2_available")?.maskWithColor(color: UIColor(named: "CLR_LABEL_TEXT_WHITE")!)
                self.marketplaceFavBtn.setImage(image, for: .normal)
            }
        }
    }
    
    var cellLockedImageString: String? {
        didSet {
            if cellLockedImageString == nil {
                lockImageView.image = nil
            } else {
                lockImageView.image = UIImage(named: cellLockedImageString!)
            }
        }
    }


    weak var delegate : SCMarketplaceOverviewTableViewCellDelegate?

    func showNewRibbon(_ show : Bool, color: UIColor){
        if !show {
            self.ribbonImageView.isHidden = true
            self.ribbonLabel.isHidden = true
        } else {
            self.ribbonImageView.isHidden = false
            self.ribbonLabel.isHidden = false
            
            let newImage = UIImage(named:"ribbon_top_left")!.maskWithColor(color: color)
            self.ribbonImageView.image = newImage
            self.ribbonLabel.text = "s_001_002_003_004_ribbon_label_new_item".localized()
            self.ribbonLabel.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 4));
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupAccessibilityIDs()
        
        // Initialization code
        self.marketplaceCellImageBackView!.layer.cornerRadius = 10.0
        self.marketplaceCellImageBackView!.clipsToBounds = true
        
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.marketplaceCellTitleLabel.accessibilityIdentifier = "lbl_title"
        self.marketplaceCellLabel.accessibilityIdentifier = "lbl_detail"
        self.marketplaceCellImageView.accessibilityIdentifier = "img_service"
        self.marketplaceFavBtn.accessibilityIdentifier = "btn_favorites"
        self.lockImageView.accessibilityIdentifier = "img_lock"
        self.ribbonImageView.accessibilityIdentifier = "img_ribbon"
        self.ribbonLabel.accessibilityIdentifier = "lbl_ribbon"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func favBtnWasPressed(_ sender: Any) {
        // We can only change the favorite state when the user is logged in
        if (SCAuth.shared.isUserLoggedIn()){
            self.delegate?.favoriteStateShouldChange(for: self.contentID, newFavSelected: !favSelected, cell: self)
        } else {
            self.delegate?.showLoginNeededNotificationScreen()
        }
    }
}

