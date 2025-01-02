//
//  SCWasteCalendarTableViewHeader.swift
//  OSCA
//
//  Created by Michael on 30.08.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCWasteCalendarTableViewHeaderCell: UITableViewCell {

    @IBOutlet weak var dayLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.dayLabel.adaptFontSize()
        self.accessoryType = UITableViewCell.AccessoryType.none
    }

    func set(title: String) {
        self.dayLabel.text = title
        self.dayLabel.adjustsFontForContentSizeCategory = true
        self.dayLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 17, maxSize: 30)

    }
}
