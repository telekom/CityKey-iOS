/*
Created by Michael on 03.11.18.
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
import Kingfisher

/**
 * @brief SCCarouselIconCollectionViewCell should only be used
 * by the SCCarouselComponentViewController
 *
 * SCCarouselIconCollectionViewCell is an tile for thre SCCarouselComponentViewController
 * Use the SCBaseComponentItem to set the content property of the tile.
 * The delgate is used by the SCCarouselComponentViewController to
 * get tap events.
 */
class SCCarouselIconCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageBackView: UIView!
    @IBOutlet weak var interestTitleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var lockImageView: UIImageView!
    @IBOutlet weak var ribbonImageView: UIImageView!
    @IBOutlet weak var ribbonLabel: UILabel!

    var tapGesture : UITapGestureRecognizer?

    weak var delegate : SCCarouselCollectionViewCellDelegate?
    
    var content: SCBaseComponentItem? {
        didSet {
            self.updateUI()
        }
    }
    
    private func showNewRibbon(_ show : Bool, color: UIColor){
        if !show {
            self.ribbonImageView.isHidden = true
            self.ribbonLabel.isHidden = true
        } else {
            self.ribbonImageView.isHidden = false
            self.ribbonLabel.isHidden = false
            
            let newImage = UIImage(named:"ribbon_75pt")!.maskWithColor(color: color)
            self.ribbonImageView.image = newImage
            self.ribbonLabel.text = "s_001_002_003_004_ribbon_label_new_item".localized()
            self.ribbonLabel.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 4));
        }
    }

    private func updateUI()
    {
        if let content = content {
            
            //adaptive Font Size
            interestTitleLabel.adaptFontSize()

            lockImageView.image = content.itemLockedDueAuth ? UIImage(named: "icon_locked_content") : content.itemLockedDueResidence  ? UIImage(named: "icon_limited_content") :  nil

            showNewRibbon(content.itemIsNew, color: content.itemColor)

            imageView.image = nil
            iconImageView.image = nil
            imageView.image = UIImage(named: content.itemImageURL!.absoluteUrlString())
            interestTitleLabel.text = content.itemTitle
            if (tapGesture == nil) {
                tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.teaserWasPressed))
                self.addGestureRecognizer(tapGesture!)
                
            }
       } else {
            imageView.image = nil
            iconImageView.image = nil
            tapGesture = nil
            lockImageView.image = nil
            showNewRibbon(false, color: .clear)
       }
        self.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageBackView.layer.cornerRadius = 10.0
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.4
        self.layer.shadowOffset = CGSize(width: 3, height: 3)
        
        self.clipsToBounds = false
        self.imageBackView.clipsToBounds = true

    }
    
    @objc func teaserWasPressed() {
        if let item = content {
            self.delegate?.didSelectCarouselItem(item: item)
        }
    }
}
