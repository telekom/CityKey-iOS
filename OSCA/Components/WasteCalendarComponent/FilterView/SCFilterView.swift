//
//  SCFilterView.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 01/09/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
