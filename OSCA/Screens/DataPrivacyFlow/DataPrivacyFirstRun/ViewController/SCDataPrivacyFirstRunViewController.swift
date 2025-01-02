//
//  SCDataPrivacyFirstRunViewController.swift
//  OSCA
//
//  Created by Bharat Jagtap on 30/06/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCDataPrivacyFirstRunViewController: UIViewController {
    
    var presenter : SCDataPrivacyFirstRunPresenting!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var changeSettingsButton : SCCustomButton!
    @IBOutlet weak var acceptAllButton : SCCustomButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupAccessibility()
        presenter.setDisplay(self)
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refreshNavigationBarStyle()
        presenter.viewWillAppear()
    }
    
    func setupUI() {
        
        changeSettingsButton.customizeBlueStyleLight()
        acceptAllButton.customizeBlueStyle()
        changeSettingsButton.setTitle(LocalizationKeys.DataPrivacyFirstRun.dialogDpnSettingsChangeBtn.localized(), for: .normal)
        acceptAllButton.setTitle(LocalizationKeys.DataPrivacyFirstRun.dialogDpnSettingsAcceptAllBtn.localized(), for: .normal)
        
        descriptionLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .callout, size: 16, maxSize: nil)

        changeSettingsButton.titleLabel?.adjustsFontForContentSizeCategory = true
        changeSettingsButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .subheadline, size: 15, maxSize: (UIScreen.main.bounds.size.width) == 320 ? 22.0 : 30.0)

        acceptAllButton.titleLabel?.adjustsFontForContentSizeCategory = true
        acceptAllButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .subheadline, size: 15, maxSize: (UIScreen.main.bounds.size.width) == 320 ? 22.0 : 30.0)
    }
    
    func setupAccessibility() {
        
        descriptionLabel.accessibilityTraits = .staticText
        descriptionLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        changeSettingsButton.accessibilityTraits = .button
        changeSettingsButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        acceptAllButton.accessibilityTraits = .button
        acceptAllButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
    }
    
    @IBAction func changeSettingsClicked(_ sender: Any) {
        presenter.changeSettingsPressed()
    }
    
    
    @IBAction func acceptAllClicked(_ sender: Any) {
        presenter.acceptAllPressed()
    }
}
