//
//  SCEgovCategoryCell.swift
//  OSCA
//
//  Created by Bharat Jagtap on 20/04/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import CoreGraphics

class SCEgovCategoryCell: UICollectionViewCell {
 
    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var titleLabel : UILabel!
    
    let cornerRadius : CGFloat = 10.0
    
    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.layer.cornerRadius = cornerRadius
        contentView.layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
        layer.shadowRadius = 3.0
        layer.shadowOpacity = 0.6
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = kColor_cityColor.cgColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 17, maxSize: (UIScreen.main.bounds.size.width) == 320 ? 17 : 22)

        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: cornerRadius
        ).cgPath
    }
    
}
