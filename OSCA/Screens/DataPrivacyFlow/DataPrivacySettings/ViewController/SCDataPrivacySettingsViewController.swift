//
//  SCDataPrivacySettingsViewController.swift
//  OSCA
//
//  Created by Bharat Jagtap on 30/06/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCDataPrivacySettingsViewController: UIViewController {
    
    var presenter : SCDataPrivacySettingsPresenting!
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var descriptionLabel : UILabel!
    @IBOutlet weak var moengageOptionView : SCPrivacySettingsOptionView!
    @IBOutlet weak var adjustOptionView : SCPrivacySettingsOptionView!
        
    @IBOutlet weak var acceptSelectedButton : SCCustomButton!
    @IBOutlet weak var acceptAllButton : SCCustomButton!
    @IBOutlet weak var dataPrivacyLinkButton : SCCustomButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupAccessibility()
        presenter.setDisplay(self)
        presenter.viewDidLoad()
    }
    
    func setupUI() {
        
        acceptSelectedButton.customizeBlueStyleLight()
        acceptSelectedButton.setTitle(LocalizationKeys.DataPrivacySettings.dialogDpnSettingsAcceptChosenBtn.localized(),
                                      for: .normal)
        
        acceptAllButton.customizeBlueStyle()
        acceptAllButton.setTitle(LocalizationKeys.DataPrivacySettings.dialogDpnSettingsAcceptAllBtn.localized(),
                                 for: .normal)
        
        dataPrivacyLinkButton.customizeBlueStyleNoBorder()
        dataPrivacyLinkButton.setTitle(LocalizationKeys.DataPrivacySettings.dialogDpnSettingsDataSecurityLink.localized(),
                                       for: .normal)
        
        moengageOptionView.iconImageView.image = UIImage(named: "icon_tools_required_data_privacy")?.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK") ?? UIColor.darkGray)
        adjustOptionView.iconImageView.image = UIImage(named: "icon_analytics_tool_data_privacy")?.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK") ?? UIColor.darkGray)
        moengageOptionView.permissionSwitch.isOn = true
        moengageOptionView.permissionSwitch.isEnabled = false

        moengageOptionView.permissionSwitch.customise(tintColor: UIColor.swithStateOnWithDisabled, backgroundColor: UIColor.switchDisabled)
        adjustOptionView.permissionSwitch.customise(tintColor: UIColor.switchStateOn, backgroundColor: UIColor.switchStateOff)

        adjustOptionView.descriptionLabel.numberOfLines = 2
        
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .callout, size: 16, maxSize: nil)
      
        descriptionLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .callout, size: 16, maxSize: nil)

        acceptSelectedButton.titleLabel?.adjustsFontForContentSizeCategory = true
        acceptSelectedButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .subheadline, size: 15, maxSize: (UIScreen.main.bounds.size.width) == 320 ? 22.0 : 30.0)

        acceptAllButton.titleLabel?.adjustsFontForContentSizeCategory = true
        acceptAllButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .subheadline, size: 15, maxSize: (UIScreen.main.bounds.size.width) == 320 ? 22.0 : 30.0)

        dataPrivacyLinkButton.titleLabel?.adjustsFontForContentSizeCategory = true
        dataPrivacyLinkButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .caption1, size: 12, maxSize: (UIScreen.main.bounds.size.width) == 320 ? 22.0 : 30.0)

    }
    
    func setupAccessibility() {
        
        titleLabel.accessibilityIdentifier = "titleLabel"
        titleLabel.accessibilityTraits = .staticText
        titleLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()

        descriptionLabel.accessibilityIdentifier = "descriptionLabel"
        descriptionLabel.accessibilityTraits = .staticText
        descriptionLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()

        acceptSelectedButton.accessibilityIdentifier = "acceptSelectedButton"
        acceptSelectedButton.accessibilityTraits = .button
        acceptSelectedButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        acceptAllButton.accessibilityIdentifier = "acceptAllButton"
        acceptAllButton.accessibilityTraits = .button
        acceptAllButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()

        dataPrivacyLinkButton.accessibilityIdentifier = "dataPrivacyLinkButton"
        dataPrivacyLinkButton.accessibilityTraits = .button
        dataPrivacyLinkButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()


        moengageOptionView.iconImageView.isAccessibilityElement = false
        moengageOptionView.titleLabel.accessibilityIdentifier = "moengageOptionView.titleLabel"
        moengageOptionView.titleLabel.accessibilityTraits = .staticText
        moengageOptionView.titleLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        moengageOptionView.descriptionLabel.accessibilityIdentifier = "moengageOptionView.descriptionLabel"
        moengageOptionView.descriptionLabel.accessibilityTraits = .staticText
        moengageOptionView.descriptionLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        moengageOptionView.permissionSwitch.accessibilityIdentifier = "moengageOptionView.permissionSwitch"
        moengageOptionView.permissionSwitch.accessibilityTraits = .button
        moengageOptionView.permissionSwitch.accessibilityLanguage = SCUtilities.preferredContentLanguage()

        moengageOptionView.expandCollapseButton.accessibilityIdentifier = "moengageOptionView.expandCollapseButton"
        moengageOptionView.expandCollapseButton.accessibilityTraits = .button
        moengageOptionView.expandCollapseButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()

        
        adjustOptionView.iconImageView.isAccessibilityElement = false
        adjustOptionView.titleLabel.accessibilityIdentifier = "adjustOptionView.titleLabel"
        adjustOptionView.titleLabel.accessibilityTraits = .staticText
        adjustOptionView.titleLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        adjustOptionView.descriptionLabel.accessibilityIdentifier = "adjustOptionView.descriptionLabel"
        adjustOptionView.descriptionLabel.accessibilityTraits = .staticText
        adjustOptionView.descriptionLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        adjustOptionView.permissionSwitch.accessibilityIdentifier = "adjustOptionView.permissionSwitch"
        adjustOptionView.permissionSwitch.accessibilityTraits = .button
        adjustOptionView.permissionSwitch.accessibilityLanguage = SCUtilities.preferredContentLanguage()

        adjustOptionView.expandCollapseButton.accessibilityIdentifier = "adjustOptionView.expandCollapseButton"
        adjustOptionView.expandCollapseButton.accessibilityTraits = .button
        adjustOptionView.expandCollapseButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        adjustOptionView.permissionSwitch.accessibilityHint = "accessibility_privacy_settings_hint".localized()
        adjustOptionView.permissionSwitch.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }

    
    @IBAction func acceptAllClicked(_ sender: Any) {
        presenter.acceptAllPressed()
    }
    
    @IBAction func acceptSelectedClicked(_ sender: Any) {
        
        presenter.acceptSelectedPressed(adjustSwitchStatus: adjustOptionView.permissionSwitch.isOn)
    }
    
    @IBAction func dataPrivacyNoticeLinkClicked(_ sender: Any) {        
        presenter.dataPrivacyLinkPressed()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        if #available(iOS 13.0, *) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                adjustOptionView.iconImageView.image = adjustOptionView.iconImageView.image?.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK") ?? UIColor.darkGray)
                moengageOptionView.iconImageView.image = moengageOptionView.iconImageView.image?.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK") ?? UIColor.darkGray)

            }
        }
    }

}
