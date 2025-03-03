/*
Created by Rutvik Kanbargi on 01/09/20.
Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Rutvik Kanbargi
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

protocol SCFilterViewDelegate: AnyObject {
    func didTapOnAddress()
    func didTapOnCategory()
}

// Localization strings
let wc_002_address_filter_address_label = "Address"


class SCFilterView: UIView {
    @IBOutlet weak var addressImageView: UIImageView!
    @IBOutlet weak var addressPlaceholder: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressContainerView: UIView! {
        didSet {
            addressContainerView.addBorder()
            addressContainerView.addCornerRadius()
        }
    }

    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryPlaceholder: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryContainerView: UIView! {
        didSet {
            categoryContainerView.addBorder()
            categoryContainerView.addCornerRadius()
        }
    }

    weak var delegate: SCFilterViewDelegate?

    class func getView() -> SCFilterView? {
        return UINib(nibName: String(describing: SCFilterView.self), bundle: nil).instantiate(withOwner: nil, options: nil).first as? SCFilterView
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        addressImageView.image = UIImage(named: "location-icon-outline")?.maskWithColor(color: UIColor(named: "CLR_ICON_SCND_ACTION")!)
        categoryImageView.image = UIImage(named: "icon-category-filter")?.maskWithColor(color: UIColor(named: "CLR_ICON_SCND_ACTION")!)
        handleDynamicTypeChange()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleDynamicTypeChange),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }


    @IBAction func didTapOnAddress(_ sender: UIControl) {
        delegate?.didTapOnAddress()
    }

    @IBAction func didTapOnCategory(_ sender: UIControl) {
        delegate?.didTapOnCategory()
    }
    
    @objc private func handleDynamicTypeChange() {
        
        addressPlaceholder.adjustsFontForContentSizeCategory = true
        addressPlaceholder.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: 22)
        addressLabel.adjustsFontForContentSizeCategory = true
        addressLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: 22)
        categoryPlaceholder.adjustsFontForContentSizeCategory = true
        categoryPlaceholder.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: 22)
        categoryLabel.adjustsFontForContentSizeCategory = true
        categoryLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: 22)
    }
}
