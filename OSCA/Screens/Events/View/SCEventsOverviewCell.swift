//
//  SCEventsOverviewCell.swift
//  SmartCity
//
//  Created by Michael on 08.10.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCEventsOverviewCell: UITableViewCell {
    
    @IBOutlet weak var eventStatusLabel: UILabelInsets!
    @IBOutlet weak var eventCellDateLabel: UILabel!
    @IBOutlet weak var eventCellTitleLabel: UILabel!
    @IBOutlet weak var eventCellLabel: UILabel!
    @IBOutlet weak var eventCellImageView: UIImageView!
    @IBOutlet weak var reminerImageView: UIImageView!
    @IBOutlet weak var favouriteImageView: UIImageView!
    @IBOutlet weak var eventCellImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventCellImageViewAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventStackBottomConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupAccessibilityIDs()
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        
        self.eventCellDateLabel.accessibilityIdentifier = "lbl_date"
        self.eventCellTitleLabel.accessibilityIdentifier = "lbl_title"
        self.eventCellLabel.accessibilityIdentifier = "lbl_info"
        self.eventCellImageView.accessibilityIdentifier = "img_event"
        self.eventStatusLabel.accessibilityIdentifier = "lbl_status"
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupEventStatusLabel(_ statusColor: UIColor, statusText: String) {
        eventStatusLabel.isHidden = false
        eventStatusLabel.backgroundColor = statusColor
        eventStatusLabel.textColor = .white
        eventStatusLabel.text = statusText
        let bounds: CGRect = eventStatusLabel.bounds
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: ([.bottomLeft, .bottomRight]), cornerRadii: CGSize(width: 5.0, height: 5.0))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        eventStatusLabel.layer.mask = maskLayer
    }
}
