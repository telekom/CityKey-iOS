//
//  SCListHeaderViewController.swift
//  SmartCity
//
//  Created by Michael on 13.10.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

protocol SCListHeaderViewControllerDelegate : NSObjectProtocol
{
    func didPressMoreBtn()
}

class SCListHeaderViewController: UIViewController {

    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet var listHeaderView: UIView!
    @IBOutlet weak var listHeaderLabel: UILabel!
    weak var delegate : SCListHeaderViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.handleDynamicTypeChange()

        NotificationCenter.default.addObserver(self, selector: #selector(handleDynamicTypeChange), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }
    
    @objc private func handleDynamicTypeChange() {
        // Dynamic font
        self.listHeaderLabel.adjustsFontForContentSizeCategory = true
        self.listHeaderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 18, maxSize: 27)
        self.moreBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        self.moreBtn.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 14, maxSize: 25)
    }

    func customize(color : UIColor) {
        self.listHeaderView.backgroundColor = color
    }
    
    
    func update(headerText : String, accessibilityID : String) {

        //adaptive Font Size
        self.listHeaderLabel.adaptFontSize()
        
        self.listHeaderLabel.text = headerText
        self.listHeaderLabel.accessibilityIdentifier = accessibilityID
        self.listHeaderLabel.accessibilityTraits = .header
        self.listHeaderLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.moreBtn.accessibilityIdentifier = "btn_more_" + accessibilityID
        self.moreBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }

    func update(moreBtnText : String, visible: Bool) {
        self.moreBtn.titleLabel?.adaptFontSize()

        self.moreBtn.setTitle(moreBtnText,for: .normal)
        self.moreBtn.isHidden = !visible
    }

    func isMoreBtnVisible(_ visible : Bool) {
        self.moreBtn.isHidden = !visible
    }

    
    // MARK: - private methods
     @IBAction func moreBtnWasPressed(_ sender: Any) {
        self.delegate?.didPressMoreBtn()
     }

}
