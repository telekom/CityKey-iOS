//
//  FahrradparkenLocationDetailsVC+Displaying.swift
//  OSCA
//
//  Created by Bhaskar N S on 08/06/23.
//  Copyright © 2023 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

extension FahrradparkenReportedLocationDetailVC: FahrradparkenReportedLocationDetailViewDisplay {
    
    func setupUI() {
        mainCategoryView.roundCorners([.topLeft, .topRight],
                                      radius: 12.0)
        mainCategoryView.backgroundColor = UIColor(named: "CLR_NAVBAR_EXPORT")
        mainCategotyLabel.text = presenter.reportedLocation.serviceName
        serviceNameLabel.text = "#" + (presenter.reportedLocation.serviceRequestID ?? "")
        serviceRequestIdLabel.text = ""
        let attrString =  presenter.reportedLocation.description?.htmlAttributedString?.trimmedAttributedString(set: .whitespacesAndNewlines)
        if let attrString = attrString {
            serviceDescriptionLabel.attributedText = customiseDescripton(attrString: attrString)
        } else {
            serviceDescriptionLabel.text = presenter.reportedLocation.description
        }
        serviceStatusLabel.text = presenter.reportedLocation.extendedAttributes?.markaspot?.statusDescriptiveName
        if let statusHex = presenter.reportedLocation.extendedAttributes?.markaspot?.statusHex {
            serviceStatusView.backgroundColor = UIColor(hexString: statusHex)
        }
        serviceStatusLabel.textColor = .white
        closeButton.setTitle("", for: .normal)
        closeButton.setImage(UIImage(named: "icon_close")?.withRenderingMode(.alwaysTemplate), for: .normal)
        closeButton.tintColor = UIColor(named: "CLR_NAVBAR_SOLID_ITEMS")
        moreInformationBtnLabel.text = LocalizationKeys.FahrradparkenReportedLocationDetailVC.fa006MoreInformationLabel.localized()

        if let icon = UIImage(named: "Information") {
            detailIcon.image = icon
            detailIcon.contentMode = .scaleAspectFit
        }
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    }

    private func customiseDescripton(attrString: NSAttributedString) -> NSAttributedString {
        // Create a mutable attributed string to modify the attributes
        let attributedString = NSMutableAttributedString(attributedString: attrString)

        // Set the attributes you want to apply
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15.0),
            NSAttributedString.Key.foregroundColor: UIColor(named: "CLR_LABEL_TEXT_BLACK")!
        ]

        // Apply the attributes to a specific range of the attributed string
        let range = NSRange(location: 0, length: attributedString.length)
        attributedString.addAttributes(attributes, range: range)
        return attributedString
    }
}

