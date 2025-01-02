//
//  CalendarCollectionViewCell.swift
//  Calendar
//
//  Created by Rutvik Kanbargi on 17/08/20.
//  Copyright © 2020 Rutvik Kanbargi. All rights reserved.
//

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
