//
//  SCNewsOverviewTableViewCell.swift
//  SmartCity
//
//  Created by Michael on 06.11.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

class SCNewsOverviewTableViewCell: UITableViewCell {

    @IBOutlet weak var newsCellTitleLabel: UILabel!
    @IBOutlet weak var newsCellLabel: UILabel!
    @IBOutlet weak var newsCellImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
