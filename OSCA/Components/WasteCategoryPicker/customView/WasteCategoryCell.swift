//
//  WasteCategoryCell.swift
//  OSCA
//
//  Created by Bhaskar N S on 09/05/23.
//  Copyright © 2023 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class WasteCategoryCell: UICollectionViewCell {

    @IBOutlet weak var cellLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellLabel.numberOfLines = 0
        cellLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        cellLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.width
        cellLabel.lineBreakMode = .byWordWrapping
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cellLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.width
    }

}
