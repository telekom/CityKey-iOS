//
//  SCWasteTypeLabelCell.swift
//  OSCA
//
//  Created by A118572539 on 30/12/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCWasteTypeLabelCell: UITableViewCell {
    @IBOutlet weak var wasteTypeLabel: UILabel!
    
    @IBOutlet weak var verticalView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        //adaptive Font Size
        self.wasteTypeLabel.adaptFontSize()
        self.setupAccessibilityIDs()
    }
    
    private func setupAccessibilityIDs() {
        self.wasteTypeLabel.accessibilityIdentifier = "lbl_wasteType"
        self.accessibilityIdentifier = "cell"
    }
    
    private func setupAccessibility() {
        self.wasteTypeLabel.accessibilityTraits = .staticText
        self.wasteTypeLabel.accessibilityLabel = wasteTypeLabel.text
        self.wasteTypeLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }
}
