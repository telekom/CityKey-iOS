//
//  SCRegistrationConfirmEMailFinishedVC.swift
//  SmartCity
//
//  Created by Michael on 12.03.19.
//  Copyright © 2019 Michael. All rights reserved.
//

import UIKit

class SCRegistrationConfirmEMailFinishedVC: UIViewController {

    public var presenter: SCRegistrationConfirmEMailFinishedPresenting!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var finishBtn: SCCustomButton!

    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var topImageHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var successImageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var topImageSymbolView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAccessibilityIDs()
        handleDynamicFontChange()
        
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
   }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.titleLabel.accessibilityIdentifier = "lbl_title"
        self.detailLabel.accessibilityIdentifier = "lbl_detail"

        self.finishBtn.accessibilityIdentifier = "btn_finish"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }
    
    private func handleDynamicFontChange() {
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 18, maxSize: 30)
        
        detailLabel.adjustsFontForContentSizeCategory = true
        detailLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 14, maxSize: 26)
    }
    
    @IBAction func finishBtnWasPressed(_ sender: Any) {
        self.presenter.finishedWasPressed()
       
    }
    
}

extension SCRegistrationConfirmEMailFinishedVC: SCRegistrationConfirmEMailFinishedDisplaying {
    
    func setupNavigationBar(title: String){
        self.navigationItem.title = title
        // remove the Back button
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.topItem?.title = title
        
    }
    
    func hideTopImage() {
        self.topImageHeightConstraint.constant = 0.0
        self.topImageView.isHidden = true
        self.topImageSymbolView.isHidden = true
    }

    func setupUI(titleText: String, detailText: String, btnText: String, topImageSymbol: UIImage){
        self.titleLabel.adaptFontSize()
        self.titleLabel.text = titleText
        
        self.detailLabel.adaptFontSize()
        self.detailLabel.text = detailText
        
        self.finishBtn.customizeBlueStyle()
        self.finishBtn.setTitle(btnText, for: .normal)
        self.finishBtn.titleLabel?.adaptFontSize()
        
        self.topImageSymbolView.image = topImageSymbol

        self.successImageTopConstraint.constant = 40.0
        
        // remove the Back button
        self.view.setNeedsLayout()

    }

    func dismissView(completion: (() -> Void)? = nil) {
        self.dismiss(animated: true, completion: completion)
    }

    func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }

}
