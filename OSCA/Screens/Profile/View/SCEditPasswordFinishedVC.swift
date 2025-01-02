//
//  SCEditPasswordFinishedVC.swift
//  SmartCity
//
//  Created by Michael on 29.03.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCEditPasswordFinishedVC: UIViewController {

    public var presenter: SCEditPasswordFinishedPresenting!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var finishBtn: SCCustomButton!
    @IBOutlet weak var closeBtn: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
        
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.closeBtn.accessibilityIdentifier = "btn_close"
        self.titleLabel.accessibilityIdentifier = "lbl_title"
        self.detailLabel.accessibilityIdentifier = "lbl_detail"
        self.finishBtn?.accessibilityIdentifier = "btn_finish"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }
    
    private func setupAccessibility(){
        self.closeBtn.accessibilityTraits = .button
        self.closeBtn.accessibilityLabel = "accessibility_btn_close".localized()
        self.closeBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }
    
    
    @IBAction func finishBtnWasPressed(_ sender: Any) {
        self.presenter.finishWasPressed()
    }
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        self.presenter.closeButtonWasPressed()
    }
}

extension SCEditPasswordFinishedVC: SCEditPasswordFinishedDisplaying {
    
    func setupUI() {
        self.navigationItem.title = "p_005_profile_password_change_title".localized()
        
        self.titleLabel.adaptFontSize()
        self.titleLabel.text = "p_006_profile_password_changed_info_done".localized()
        self.detailLabel.adaptFontSize()
        self.detailLabel.text = "p_006_profile_password_changed_info_next".localized()
        self.finishBtn.customizeBlueStyle()
        self.finishBtn.setTitle("r_005_registration_success_login_btn".localized(), for: .normal)
        self.finishBtn.titleLabel?.adaptFontSize()
        
        titleLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .title3, size: 20, maxSize: 30)
        detailLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 14, maxSize: 30)
        
        // remove the Back button
        self.navigationItem.hidesBackButton = true
        
        self.view.setNeedsLayout()
    }
    
    func dismissView(completion: (() -> Void)? = nil) {
        self.dismiss(animated: false, completion: completion)
    }

    func setFinishButtonState(_ state : SCCustomButtonState){
        self.finishBtn.btnState = state
    }

    func dismiss(completion: (() -> Void)?) {
        self.dismiss(animated: true, completion: completion)
    }
}
