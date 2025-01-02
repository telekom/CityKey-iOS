//
//  SCDataPrivacyNoticeViewController.swift
//  OSCA
//
//  Created by Bharat Jagtap on 21/05/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCDataPrivacyNoticeViewController: UIViewController {

    @IBOutlet weak var okButton : SCCustomButton!
    @IBOutlet weak var showDPNButton : SCCustomButton!
    @IBOutlet weak var textView : UITextView!
    var presenter : SCDataPrivacyNoticePresenting!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.setDisplay(self)
        setupUI()
        setUpAccessibility()
        presenter.viewDidLoad()
    }
    
    func setupUI() {
        okButton.customizeBlueStyle()
        showDPNButton.customizeBlueStyleLight()
        okButton.setTitle("dialog_dpn_ok_btn".localized(), for: .normal)
        showDPNButton.setTitle("dialog_dpn_updated_privacy_btn".localized(), for: .normal)
    }
    
    func setUpAccessibility() {
        
        okButton.accessibilityIdentifier = "acceptButton"
        okButton.accessibilityLabel = "dialog_dpn_ok_btn".localized()
        okButton.accessibilityTraits = .button
        okButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()

        showDPNButton.accessibilityIdentifier = "showDPNButton"
        showDPNButton.accessibilityLabel = "dialog_dpn_updated_privacy_btn".localized()
        showDPNButton.accessibilityTraits = .button
        showDPNButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }
    
    
    @IBAction func onShowDPNClicked(_ sender: Any) {
        presenter.onShowNoticeClicked()
    }
    
    @IBAction func onAcceptClicked(_ sender: Any) {
        okButton.btnState = .progress
        presenter.onAcceptClicked()
    }
}
