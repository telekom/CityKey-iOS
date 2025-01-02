//
//  SCTilesListIconCollectionViewCell.swift
//  SmartCity
//
//  Created by Michael on 03.11.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit
import Kingfisher

/**
 * @brief SCTilesListIconCollectionViewCell should only be used
 * by the SCTilesListComponentViewController
 *
 * SCTilesListIconCollectionViewCell is an tile for thre SCTilesListComponentViewController
 * Use the SCBaseComponentItem to set the content property of the tile.
 * The delgate is used by the SCTilesListComponentViewController to
 * get tap events.
 */
class SCTilesListIconCollectionViewCell: SCBaseCollectionViewCell
{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageBackView: UIView!
    @IBOutlet weak var interestTitleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var lockImageView: UIImageView!
    @IBOutlet weak var ribbonImageView: UIImageView!
    @IBOutlet weak var ribbonLabel: UILabel!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var badgeLabel: UILabel!

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

    override func updateUI()
    {
        super.updateUI()

        if let content = content {
            
            //adaptive Font Size
            interestTitleLabel.adaptFontSize()

            lockImageView.image = content.itemLockedDueAuth ? UIImage(named: "icon_locked_content") : content.itemLockedDueResidence  ? UIImage(named: "icon_limited_content") :  nil
            
            showNewRibbon(content.itemIsNew, color: content.itemColor)

            imageView.image = nil
            iconImageView.image = nil
            
            imageView.image = UIImage(named: content.itemImageURL!.absoluteUrlString())
            iconImageView.image = UIImage(named: content.itemIconURL!.absoluteUrlString())?.maskWithColor(color: UIColor(named: "CLR_LABEL_TEXT_WHITE")!)
            
            interestTitleLabel.text = content.itemTitle
            if (tapGesture == nil) {
                tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.teaserWasPressed))
                self.addGestureRecognizer(tapGesture!)
                
            }
            handleBadgePresentation(content: content)
            self.clipsToBounds = false // display subviews which will be out of bounds
       } else {
            imageView.image = nil
            iconImageView.image = nil
            tapGesture = nil
            lockImageView.image = nil
            showNewRibbon(false, color: .clear)
        }
        self.setNeedsLayout()
    }

    private func handleBadgePresentation(content: SCBaseComponentItem) {
        guard let badgeCount = content.badgeCount, !content.itemLockedDueAuth, !content.itemLockedDueResidence else {
            badgeView.isHidden = true
            badgeLabel.text = ""
            return
        }

        badgeView.isHidden = false
        badgeLabel.text = "\(badgeCount)"
        badgeView.addCornerRadius(radius: badgeView.bounds.height / 2)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageBackView.layer.cornerRadius = 10.0
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.4
        self.layer.shadowOffset = CGSize(width: 3, height: 3)
        
        self.clipsToBounds = false
        self.imageBackView.clipsToBounds = true
        
        interestTitleLabel.adjustsFontForContentSizeCategory = true
        interestTitleLabel.font = UIFont.SystemFont.medium.forTextStyle(style: .body, size: 16, maxSize: (interestTitleLabel.text?.count ?? 0 < 25) ? 30 : 25)
    }
    
}
