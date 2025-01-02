//
//  SCUserInfoBoxTableViewCell.swift
//  SmartCity
//
//  Created by Michael on 06.11.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

class SCUserInfoBoxTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var attachementImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var headlineLabel: SCTopAlignLabel!
    @IBOutlet weak var descriptionLabel: SCTopAlignLabel!
    
    @IBOutlet weak var infoReadView: UIView!

    var contentID: String?
    var infoWasRead: Bool = false {
        didSet {
            if infoWasRead {
                self.infoReadView.backgroundColor = UIColor(named: "CLR_BCKGRND")!
            } else {
                self.infoReadView.backgroundColor = kColor_cityColor
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.categoryTitleLabel.adaptFontSize()
        self.dateLabel.adaptFontSize()
        self.headlineLabel.adaptFontSize()
        self.descriptionLabel.adaptFontSize()
        
        self.setupAccessibilityIDs()
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.categoryTitleLabel.accessibilityIdentifier = "lbl_category"
        self.dateLabel.accessibilityIdentifier = "lbl_date"
        self.headlineLabel.accessibilityIdentifier = "lbl_headline"
        self.descriptionLabel.accessibilityIdentifier = "lbl_description"
        self.categoryImageView.accessibilityIdentifier = "img_category"
        self.attachementImageView.accessibilityIdentifier = "img_attach"
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                self.attachementImageView.image = self.attachementImageView.image?.maskWithColor(color: kColor_cityColor)
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(_for item: SCUserInfoBoxMessageItem) {
        categoryTitleLabel.adjustsFontForContentSizeCategory = true
        categoryTitleLabel.font = UIFont.SystemFont.medium.forTextStyle(style: .body, size: 12, maxSize: nil)
        
        dateLabel.adjustsFontForContentSizeCategory = true
        dateLabel.font = UIFont.SystemFont.medium.forTextStyle(style: .body, size: 13, maxSize: 26)
        
        headlineLabel.adjustsFontForContentSizeCategory = true
        headlineLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 15, maxSize: nil)
        
        descriptionLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 14, maxSize: nil)
        
        if let iconUrl = item.icon {
            self.categoryImageView.load(from: SCImageURL(urlString: iconUrl, persistence: false))
        } else {
            self.categoryImageView.image = nil
        }

        if (item.attachmentCount > 0) {
            self.attachementImageView.isHidden = false
            self.attachementImageView.image = self.attachementImageView.image?.maskWithColor(color: kColor_cityColor)
        } else {
            self.attachementImageView.isHidden = true
        }

        self.categoryTitleLabel.text = item.category
        self.dateLabel.text =  infoBoxDateStringFromCreationDate(date: item.creationDate)
        self.headlineLabel.text = item.headline
        self.descriptionLabel.attributedText = item.description.applyHyphenation()
        self.infoWasRead = item.isRead
    }

}
