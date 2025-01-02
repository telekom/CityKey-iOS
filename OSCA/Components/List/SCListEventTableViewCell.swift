//
//  SCListEventTableViewCell.swift
//  SmartCity
//
//  Created by Alexander Lichius on 23.09.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
enum EventStatus : String {
    case cancelled = "CANCELLED"
    case postponed = "POSTPONED"
    case soldout = "SOLDOUT"
    case available = "AVAILABLE"
}

class SCListEventTableViewCell: UITableViewCell {

    @IBOutlet weak var eventStatusLabel: UILabelInsets!
    @IBOutlet weak var reminderIcon: UIImageView!
    @IBOutlet weak var favouriteIcon: UIImageView!
    @IBOutlet weak var dateBoxView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var iconStackYConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventStackBottomConstraint: NSLayoutConstraint!

    var model: SCModelEvent? {
        didSet {
            self.configure(model!)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupAccessibility()
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupAccessibility(){
        self.locationLabel.accessibilityElementsHidden = true
        self.eventNameLabel.accessibilityElementsHidden = true
    }

    func configure(_ model: SCModelEvent) {
        locationLabel.attributedText = model.locationName.applyHyphenation()
        locationLabel.lineBreakMode = .byTruncatingTail
        locationLabel.isHidden = !self.locationLabel.text!.isEmpty ? false : true
        self.iconStackYConstraint.isActive = !self.locationLabel.text!.isEmpty ? false : true
        configureCommonEvents(model)
    }
    
    private func configureCommonEvents(_ model: SCModelEvent){
        let strikeThroughText = NSMutableAttributedString(string: model.title)
        eventStatusLabel.isHidden = false
        eventStatusLabel.layer.masksToBounds = true
        eventStatusLabel.layer.cornerRadius = 5.0
        locationLabel.autoresizingMask = [.flexibleWidth]
        
        let status = EventStatus(rawValue: model.status?.uppercased() ?? "AVAILABLE")
        switch status{
        
        case .cancelled :
            strikeThroughText.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, strikeThroughText.length))
            eventNameLabel.attributedText = strikeThroughText
            eventStatusLabel.backgroundColor = UIColor.appointmentRejected
            eventStatusLabel.text = LocalizationKeys.SCEventsOverviewTVC.e007CancelledEvents.localized()
        
        case .postponed :
            eventNameLabel.attributedText = strikeThroughText
            eventStatusLabel.backgroundColor = UIColor.postponeEventStatus
            eventStatusLabel.text = LocalizationKeys.SCEventsOverviewTVC.e007EventsNewDateLabel.localized()
        
        case .soldout :
            eventNameLabel.attributedText = strikeThroughText
            eventStatusLabel.backgroundColor = UIColor.appointmentRejected
            eventStatusLabel.text = LocalizationKeys.SCEventsOverviewTVC.e007EventsSoldOutLabel.localized()
        
        default:
            eventNameLabel.attributedText = model.title.applyHyphenation()
            eventStatusLabel.isHidden = true
        }
    }
    
    
    func configureReminder(active: Bool) {
        self.reminderIcon.isHidden = !active
    }
    
    func configureFavorite(active: Bool, customizeColor : UIColor) {
        self.favouriteIcon.isHidden = !active
        let image = self.favouriteIcon.image?.maskWithColor(color: customizeColor)
        self.favouriteIcon.image = image
    }

}

class UILabelInsets: UILabel {

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        super.drawText(in: rect.inset(by: insets))
    }
}
