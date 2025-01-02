//
//  SHListMessageCell.swift
//  SmartCity
//
//  Created by Michael on 22.10.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

class SHListMessageCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var seperator: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupAccessibility()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func setupAccessibility(){
        self.titleLabel.accessibilityElementsHidden = true
        self.messageLabel.accessibilityElementsHidden = true

        messageLabel.adjustsFontForContentSizeCategory = true
        messageLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 17, maxSize: 26)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.font = UIFont.SystemFont.medium.forTextStyle(style: .footnote, size: 12, maxSize: 18)
    }
}
