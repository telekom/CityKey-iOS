/*
Created by Bhaskar N S on 08/06/23.
Copyright © 2023 Deutsche Telekom AG - VTI Organization. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 
In accordance with Sections 4 and 6 of the License, the following exclusions apply:

    1. Trademarks & Logos – The names, logos, and trademarks of the Licensor are not covered by this License and may not be used without separate permission.
    2. Design Rights – Visual identities, UI/UX designs, and other graphical elements remain the property of their respective owners and are not licensed under the Apache License 2.0.
    3: Non-Coded Copyrights – Documentation, images, videos, and other non-software materials require separate authorization for use, modification, or distribution.

These elements are not considered part of the licensed Work or Derivative Works unless explicitly agreed otherwise. All elements must be altered, removed, or replaced before use or distribution. All rights to these materials are reserved, and Contributor accepts no liability for any infringing use. By using this repository, you agree to indemnify and hold harmless Contributor against any claims, costs, or damages arising from your use of the excluded elements.

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Bhaskar N S
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

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

