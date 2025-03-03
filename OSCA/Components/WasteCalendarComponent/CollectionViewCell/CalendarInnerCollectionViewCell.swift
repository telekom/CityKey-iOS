/*
Created by Rutvik Kanbargi on 17/08/20.
Copyright © 2020 Rutvik Kanbargi. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Copyright © 2020 Rutvik Kanbargi
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

struct CalendarCellConfig {
    var backgroundColor: UIColor
    var labelColor: UIColor
}

class CalendarInnerCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var daylabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.layer.cornerRadius = 6
            containerView.clipsToBounds = true
        }
    }
    
    private var wasteBins: [SCModelWasteBinType] = []

    private let pastDayTextColor = UIColor.lightGray.withAlphaComponent(0.4)

    func set(data: SCCalendarDate, selectedDateHash: Int?) {
        daylabel.text = data.dayString
        daylabel.adaptFontSize()
        let cellConfig = data.type.getDayViewConfig()
        daylabel.textColor = cellConfig.labelColor
        containerView.backgroundColor = cellConfig.backgroundColor
        daylabel.accessibilityElementsHidden = true

        daylabel.adjustsFontForContentSizeCategory = true
        daylabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16, maxSize: 20)
        
        self.isUserInteractionEnabled = data.type.isSelectable()
        wasteBins = data.wasteBins
        addWasteBinIcons(bins: data.wasteBins)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        addWasteBinIcons(bins: wasteBins)
    }

    private func addWasteBinIcons(bins: [SCModelWasteBinType]) {
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        var uniqueWasteTypes:[SCModelWasteBinType] = []
        bins.forEach { (bin) -> () in
            if !uniqueWasteTypes.contains (where: { $0.color == bin.color }) {
                uniqueWasteTypes.append(bin)
            }
        }

        for bin in uniqueWasteTypes {
            let view = CircleView()
            view.translatesAutoresizingMaskIntoConstraints = false
            if #available(iOS 12.0, *) {
                if traitCollection.userInterfaceStyle == .dark && bin.color == "#1A171B" {
                    view.backgroundColor = UIColor(hexString: bin.color).lighter()
                } else {
                    view.backgroundColor = UIColor(hexString: bin.color)
                }
            } else {
                view.backgroundColor = UIColor(hexString: bin.color)
            }
            view.layer.cornerRadius = 4
            view.layer.masksToBounds = true
            stackView.addArrangedSubview(view)

            view.widthAnchor.constraint(equalToConstant: 8).isActive = true
            view.heightAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        }
    }
}

class CircleView: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.width/2.0
    }
}
