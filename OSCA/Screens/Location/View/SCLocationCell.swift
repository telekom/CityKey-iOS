//
//  SCLocationCell.swift
//  SmartCity
//
//  Created by Michael on 08.11.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

class SCLocationCell: UITableViewCell {

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var imageBackgroundBlackView: UIView!
    @IBOutlet weak var imageBackgroundView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var imageCityView: UIImageView!
    //@IBOutlet weak var imageDetailView: UIImageView!
    
    @IBOutlet weak var activitcyIndicatorWidthCinstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupAccessibilityIDs()
        // Initialization code
        if #available(iOS 13.0, *) {
            activityIndicatorView.style = .medium
        } else {
            activityIndicatorView.style = .gray
        }
    }

    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.cityLabel.accessibilityIdentifier = "lbl_select_city"
        self.stateLabel.accessibilityIdentifier = "lbl_select_state"
        self.imageCityView.accessibilityIdentifier = "img_city"
        self.accessibilityIdentifier = "cell"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func selectionModeStyle(_ selectionMode: Bool) {
        if selectionMode {
            self.activitcyIndicatorWidthCinstraint.constant = 0.0
        } else {
            self.activitcyIndicatorWidthCinstraint.constant = 24.0
            
        }
    
    }
}
