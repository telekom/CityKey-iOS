//
//  SCDatePickerSectionHeaderViewCollectionReusableView.swift
//  SmartCity
//
//  Created by Michael on 28.08.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCDatePickerSectionHeaderViewCollectionReusableView: UICollectionReusableView {
        
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupAccessibilityIDs()
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        
        self.titleLabel.accessibilityIdentifier = "lbl_month_title"
    }

}
