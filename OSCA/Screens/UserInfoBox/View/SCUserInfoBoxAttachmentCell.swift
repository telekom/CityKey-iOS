//
//  SCUserInfoBoxAttachmentCell.swift
//  SmartCity
//
//  Created by Michael on 12.12.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCUserInfoBoxAttachmentCell: UITableViewCell {

    @IBOutlet weak var attTypeImageView: UIImageView!
    @IBOutlet weak var attTitleLbl: UILabel!
    @IBOutlet weak var topSeparator: UIView!
    @IBOutlet weak var bottomSeparator: UIView!
    @IBOutlet weak var backView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
