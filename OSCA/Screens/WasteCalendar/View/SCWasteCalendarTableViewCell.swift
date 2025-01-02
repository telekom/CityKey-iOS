//
//  SCWasteCalendarTableViewCell.swift
//  OSCA
//
//  Created by Michael on 27.08.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCWasteCalendarTableViewCell: UITableViewCell {

    @IBOutlet weak var wasteImageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var reminderImageView: UIImageView!
    @IBOutlet weak var arrowImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.title.adaptFontSize()
        self.contentView.backgroundColor = UIColor.clear
        //self.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        self.accessoryType = UITableViewCell.AccessoryType.none
    }

    func set(wasteType: String, symbolColor: UIColor, isReminderSet: Bool) {
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .dark && symbolColor.hexString == "1A171B" {
                self.wasteImageView.image = UIImage(named: "icon-yellow-trash")!.maskWithColor(color: symbolColor.lighter() ?? .white)
            } else {
                self.wasteImageView.image = UIImage(named: "icon-yellow-trash")!.maskWithColor(color: symbolColor)
            }
        } else {
            self.wasteImageView.image = UIImage(named: "icon-yellow-trash")!.maskWithColor(color: symbolColor)
        }
        self.title.text = wasteType
        reminderImageView.isHidden = !isReminderSet
        reminderImageView.image = UIImage(named: "activated")!.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!)
        self.title.adjustsFontForContentSizeCategory = true
        self.title.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 17, maxSize: nil)

    }

}
