//
//  SCColorOptionCell.swift
//  OSCA
//
//  Created by A118572539 on 06/01/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCColorOptionCell: UITableViewCell {
    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var colorTitleLabel: UILabel!

    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var separator: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        colorButton.setTitle("", for: .normal)
        
        //adaptive Font Size
        self.colorTitleLabel.adaptFontSize()
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        separator.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
    }
    
    private func setupAccessibilityIDs() {
        self.colorTitleLabel.accessibilityIdentifier = "lbl_ColorName"
        self.rightImageView.accessibilityIdentifier = "img_rightSelected"
        self.accessibilityIdentifier = "cell"
    }
    
    private func setupAccessibility() {
        self.colorTitleLabel.accessibilityTraits = .staticText
        self.colorTitleLabel.accessibilityLabel = colorTitleLabel.text
        self.colorTitleLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
