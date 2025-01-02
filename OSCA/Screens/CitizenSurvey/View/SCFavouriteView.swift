//
//  SCFavouriteView.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 11/12/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCFavouriteView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()

        setupView()
    }

    private func setupView() {
        backgroundColor = .appointmentRejected
        addCornerRadius(radius: (frame.height - 6)/2)

        let label = UILabel(frame: self.bounds)
        label.text = LocalizationKeys.SCFavouriteView.cs002FavoredListItemLabel.localized()//.uppercased()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        addSubview(label)
    }
}
