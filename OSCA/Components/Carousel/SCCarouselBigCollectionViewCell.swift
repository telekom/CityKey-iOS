//
//  SCCarouselBigCollectionViewCell.swift
//  SmartCity
//
//  Created by Michael on 15.10.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit
import Kingfisher

/**
 * @brief SCCarouselBigCollectionViewCell should only be used
 * by the SCCarouselComponentViewController
 *
 * SCCarouselBigCollectionViewCell is an tile for thre SCCarouselComponentViewController
 * Use the SCBaseComponentItem to set the content property of the tile.
 * The delegate is used by the SCCarouselComponentViewController to
 * get tap events.
 */
class SCCarouselBigCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var teaserLabel: SCTopAlignLabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lockImageView: UIImageView!
    @IBOutlet weak var ribbonImageView: UIImageView!
    @IBOutlet weak var ribbonLabel: UILabel!

    
    weak var delegate : SCCarouselCollectionViewCellDelegate?

    var tapGestureImage : UITapGestureRecognizer?
    var tapGestureText : UITapGestureRecognizer?
    var tapGestureTitle : UITapGestureRecognizer?

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
            
            teaserLabel.adaptFontSize()
            titleLabel.adaptFontSize()

            lockImageView.image = content.itemLockedDueAuth ? UIImage(named: "icon_locked_content") : content.itemLockedDueResidence  ? UIImage(named: "icon_limited_content") :  nil

            showNewRibbon(content.itemIsNew, color: content.itemColor)
            
            imageView.image = nil
            imageView.image = UIImage(named: content.itemImageURL!.absoluteUrlString())
            
            teaserLabel.text = content.itemTeaser
            titleLabel.text = content.itemTitle
            colorView.backgroundColor = content.itemColor
            if (tapGestureTitle == nil) {
                titleLabel.isUserInteractionEnabled = true
                tapGestureTitle = UITapGestureRecognizer(target: self, action: #selector(self.contentWasPressed))
                self.titleLabel.addGestureRecognizer(tapGestureTitle!)
                
            }
            if (tapGestureText == nil) {
                teaserLabel!.isUserInteractionEnabled = true
                tapGestureText = UITapGestureRecognizer(target: self, action: #selector(self.contentWasPressed))
                self.teaserLabel.addGestureRecognizer(tapGestureText!)

            }
            if (tapGestureImage == nil) {
                imageView.isUserInteractionEnabled = true
                tapGestureImage = UITapGestureRecognizer(target: self, action: #selector(self.contentWasPressed))
                self.imageView.addGestureRecognizer(tapGestureImage!)
                
            }
            //backgroundView.backgroundColor = .clear //content.color
        } else {
            imageView.image = nil
            teaserLabel.text = nil
            titleLabel.text = nil
            tapGestureText = nil
            tapGestureImage = nil
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
    
    @objc func contentWasPressed() {
        if let item = content {
            self.delegate?.didSelectCarouselItem(item: item)
        }
    }
    
    @IBAction func shareBtnWasPressed(_ sender: Any) {
        

    }
}
