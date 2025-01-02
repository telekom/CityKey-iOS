//
//  SCEgovServiceCell.swift
//  OSCA
//
//  Created by Bharat Jagtap on 21/04/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCEgovServiceCell: UITableViewCell {

    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var descLabel : UILabel!
    @IBOutlet weak var typeLabel : UILabel!
    @IBOutlet weak var typeImageView : UIImageView!
    
    override var accessibilityTraits: UIAccessibilityTraits {
        get { return .none }
        set {}
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 15, maxSize: nil)
        descLabel.adjustsFontForContentSizeCategory = true
        descLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .subheadline, size: 15, maxSize: nil)
        typeLabel.adjustsFontForContentSizeCategory = true
        typeLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .subheadline, size: 15, maxSize: nil)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
