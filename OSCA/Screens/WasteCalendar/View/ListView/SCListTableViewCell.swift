//
//  SCListTableViewCell.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 11/09/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCListTableViewCell: UITableViewCell {

    @IBOutlet weak var itemNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
