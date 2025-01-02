//
//  SCBasicPOIGuideCategoryTableViewCell.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 26/02/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCBasicPOIGuideCategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var checkmarkIcon: UIImageView!

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
    private func setupAccessibilityIDs() {
        categoryLabel.accessibilityIdentifier = "lbl_select_category"
        accessibilityIdentifier = "cell"
    }

    func set(title: String) {
        categoryLabel.text = title
    }
}
