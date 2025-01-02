//
//  SCBasicPOIGuideCategoryTableViewHeaderCell.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 26/02/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCBasicPOIGuideCategoryTableViewHeaderCell: UITableViewCell {

    @IBOutlet weak var categoryGroupLabel: UILabel!
    @IBOutlet weak var imageCategory: UIImageView!
        
    override func awakeFromNib() {
        super.awakeFromNib()

        //adaptive Font Size
        self.categoryGroupLabel.adaptFontSize()
        self.setupAccessibilityIDs()
    }

    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.categoryGroupLabel.accessibilityIdentifier = "lbl_select_category_group"
        self.imageCategory.accessibilityIdentifier = "img_city"
        self.accessibilityIdentifier = "cell"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func set(title: String, image: SCImageURL?) {
        self.categoryGroupLabel.text = title
        self.imageCategory.load(from: image)
    }

}


