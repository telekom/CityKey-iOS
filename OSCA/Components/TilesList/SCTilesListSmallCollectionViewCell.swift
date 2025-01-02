//
//  SCTilesListSmallCollectionViewCell.swift
//  SmartCity
//
//  Created by Michael on 03.11.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit
import Kingfisher

/**
 * @brief SCTilesListSmallCollectionViewCell should only be used
 * by the SCTilesListComponentViewController
 *
 * SCTilesListSmallCollectionViewCell is an tile for thre SCTilesListComponentViewController
 * Use the SCBaseComponentItem to set the content property of the tile.
 * The delgate is used by the SCTilesListComponentViewController to
 * get tap events.
 */
class SCTilesListSmallCollectionViewCell: SCBaseCollectionViewCell
{

    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var interestTitleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var lockImageView: UIImageView!
    @IBOutlet weak var ribbonImageView: UIImageView!
    @IBOutlet weak var ribbonLabel: UILabel!

    
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

            iconImageView.image = nil
            colorView.backgroundColor = content.itemColor
            iconImageView.image = UIImage(named: content.itemIconURL!.absoluteUrlString())
            interestTitleLabel.text = content.itemTitle
            if (tapGesture == nil) {
                tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.teaserWasPressed))
                self.addGestureRecognizer(tapGesture!)
                
            }
        } else {
            iconImageView.image = nil
            tapGesture = nil
            lockImageView.image = nil
            showNewRibbon(false, color: .clear)
        }
        self.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.colorView.layer.cornerRadius = 10.0
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.4
        self.layer.shadowOffset = CGSize(width: 3, height: 3)
        
        self.clipsToBounds = false
        self.colorView.clipsToBounds = true
        
    }
    

}
