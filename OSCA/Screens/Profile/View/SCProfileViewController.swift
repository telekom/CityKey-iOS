/*
Created by Michael on 04.10.18.
Copyright © 2018 Michael. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Copyright © 2018 Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

/**
 * ViewController class for the profile section of the
 * Application
 */
class SCProfileViewController: UIViewController  {

    public var presenter: SCProfilePresenting!
    //
    // Outlets for PGenral Profile Outlets
    //
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var topImageView: UIImageView!
    
    @IBOutlet weak var closeBtn: UIBarButtonItem!
    //
    // Outlets for Personal Data
    //
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var birthdateDescLabel: UILabel!
    @IBOutlet weak var birthdateLabel: UILabel!
    @IBOutlet weak var residenceDescLabel: UILabel!
    @IBOutlet weak var residenceLabel: UILabel!
    
    @IBOutlet weak var personalDataEditButton: UIButton!

    //
    // Outlets for User Account
    //
    @IBOutlet weak var userAccountLabel: UILabel!
    
    @IBOutlet weak var emailDescLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordDescLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    
    @IBOutlet weak var userAccountEditButton: UIButton!

    //
    // Outlets for Help/ FAQ
    //
    
    @IBOutlet weak var helpFAQSectionHeaderLabel: UILabel!
    @IBOutlet weak var helpFAQLinkLabel: UILabel!
    
    //
    // Ooutlets for Legal Links
    //
    // impressum
    @IBOutlet weak var impressumContainer: UIView!
    @IBOutlet weak var impressumLinkLabel: UILabel!
    
    // security link
    @IBOutlet weak var securityLinkContainer: UIView!
    @IBOutlet weak var securityLinkLabel: UILabel!
    
    // Data Privacy Settings
    @IBOutlet weak var dataPrivacySettingsContainer: UIView!
    @IBOutlet weak var dataPrivacySettingsLabel: UILabel!

    // accesibility statement
    @IBOutlet weak var accessibilityStatementContainer: UIView!
    @IBOutlet weak var accessibilityStatementLabel: UILabel!
    
    @IBOutlet weak var feedbackContainer: UIView!
    @IBOutlet weak var feedbackLabel: UILabel!

    @IBOutlet weak var softwareLicenseContainer: UIView!
    @IBOutlet weak var softwareLicenseLabel: UILabel!

    
    @IBOutlet weak var imgArrowHelpFAQ: UIImageView!
    @IBOutlet weak var imgArrowDataPrivacy: UIImageView!
    @IBOutlet weak var imgArrowDataPrivacySettings: UIImageView!
    @IBOutlet weak var imgArrowImpressum: UIImageView!
    @IBOutlet weak var imgArrowAccessibilityStatement: UIImageView!
    @IBOutlet weak var imgArrowFeedback: UIImageView!
    @IBOutlet weak var imgArrowSoftwareLicense: UIImageView!

    
    @IBOutlet weak var imgHelpFAQ: UIImageView!
    @IBOutlet weak var imgDataPrivacy: UIImageView!
    @IBOutlet weak var imgDataPrivacySettings: UIImageView!
    @IBOutlet weak var imgImpressum: UIImageView!
    @IBOutlet weak var imgAccessibilityStatement: UIImageView!
    @IBOutlet weak var imgFeedback: UIImageView!
    @IBOutlet weak var imgSoftwareLicense: UIImageView!
    
    //
    // Outlets for Logout
    //
    @IBOutlet weak var logoutBtn: SCCustomButton!
    
    // For App Preview Mode UI
    @IBOutlet weak var appPreviewModeStackView: UIStackView!
    @IBOutlet weak var liveModeRadioView: SCRadioToggleView!
    @IBOutlet weak var previewModeRadioView: SCRadioToggleView!
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var citykeyHelpWebsiteBtn: UIButton!
    
    // the refreshControl
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "p_001_profile_title".localized()
        
        self.shouldNavBarTransparent = false
        
        self.adaptFontSizes()
        self.setDescriptionTexts()
        
        self.addRefreshToPull(on: self.scrollView, topYPosition: 0.0)
        
        self.logoutBtn.customizeBlueStyle()
        
        self.refreshImagesForLightDarkMode()

        addGestureRecogniserForModeUI()
        
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
        
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshNavigationBarStyle()
    }

    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.closeBtn.accessibilityIdentifier = "btn_close"
        self.residenceDescLabel.accessibilityIdentifier = "lbl_residence_description"
        self.residenceLabel.accessibilityIdentifier = "lbl_residence"
        self.birthdateDescLabel.accessibilityIdentifier = "lbl_birthdate_description"
        self.birthdateLabel.accessibilityIdentifier = "lbl_birthdate"
        self.personalDataEditButton.accessibilityIdentifier = "btn_personal_data_edit"
        self.userAccountLabel.accessibilityIdentifier = "lbl_user_account"
        self.emailDescLabel.accessibilityIdentifier = "lbl_email_description"
        self.emailLabel.accessibilityIdentifier = "lbl_email"
        self.passwordDescLabel.accessibilityIdentifier = "lbl_password_description"
        self.passwordLabel.accessibilityIdentifier = "lbl_password"
        self.userAccountEditButton.accessibilityIdentifier = "btn_account_edit"
        self.helpFAQSectionHeaderLabel.accessibilityIdentifier = "lbl_HelpSectionHeader"
        self.helpFAQLinkLabel.accessibilityIdentifier = "link_help_faq"

        self.impressumLinkLabel.accessibilityIdentifier = "impressumLinkLabel"
        self.impressumContainer.accessibilityIdentifier = "impressumContainer"
        self.securityLinkLabel.accessibilityIdentifier = "securityLinkLabel"
        self.securityLinkContainer.accessibilityIdentifier = "securityLinkContainer"
        self.dataPrivacySettingsLabel.accessibilityIdentifier = "dataPrivacySettingsLabel"
        self.dataPrivacySettingsContainer.accessibilityIdentifier = "dataPrivacySettingsContainer"
        self.accessibilityStatementLabel.accessibilityIdentifier = "accessibilityStatementLabel"
        self.accessibilityStatementContainer.accessibilityIdentifier = "accessibilityStatementContainer"
        self.feedbackLabel.accessibilityIdentifier = "feedbackLabel"
        self.feedbackContainer.accessibilityIdentifier = "feedbackContainer"

        self.softwareLicenseLabel.accessibilityIdentifier = "softwareLicenseLabel"
        self.softwareLicenseContainer.accessibilityIdentifier = "softwareLicenseContainer"

        self.logoutBtn.accessibilityIdentifier = "btn_logout"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"

        self.liveModeRadioView.isAccessibilityElement = true
        self.liveModeRadioView.accessibilityIdentifier = "view_live_mode"
        self.previewModeRadioView.isAccessibilityElement = true
        self.previewModeRadioView.accessibilityIdentifier = "view_preview_mode"
    }

    private func setupAccessibility(){
       
        self.closeBtn.accessibilityTraits = .button
        self.closeBtn.accessibilityLabel = "accessibility_btn_close".localized()
        self.closeBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.impressumLinkLabel.isAccessibilityElement = false
        self.impressumContainer.isAccessibilityElement = true
        self.impressumContainer.accessibilityTraits = .link
        
        self.securityLinkLabel.isAccessibilityElement = false
        self.securityLinkContainer.isAccessibilityElement = true
        self.securityLinkContainer.accessibilityTraits = .link

        self.dataPrivacySettingsLabel.isAccessibilityElement = false
        self.dataPrivacySettingsContainer.isAccessibilityElement = true
        self.dataPrivacySettingsContainer.accessibilityTraits = .link

        self.accessibilityStatementLabel.isAccessibilityElement = false
        self.accessibilityStatementContainer.isAccessibilityElement = true
        self.accessibilityStatementContainer.accessibilityTraits = .link
        
        self.feedbackLabel.isAccessibilityElement = false
        self.feedbackContainer.isAccessibilityElement = true
        self.feedbackContainer.accessibilityTraits = .link

        self.softwareLicenseLabel.isAccessibilityElement = false
        self.softwareLicenseContainer.isAccessibilityElement = true
        self.softwareLicenseContainer.accessibilityTraits = .link

        self.liveModeRadioView.accessibilityTraits = .staticText
        self.liveModeRadioView.accessibilityLabel = liveModeRadioView.titleLabel.text
        self.liveModeRadioView.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.previewModeRadioView.accessibilityTraits = .staticText
        self.previewModeRadioView.accessibilityLabel = previewModeRadioView.titleLabel.text
        self.previewModeRadioView.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.modeLabel.accessibilityTraits = .staticText
        self.modeLabel.accessibilityLabel = modeLabel.text
        self.modeLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        self.citykeyHelpWebsiteBtn.accessibilityElementsHidden = true
        self.helpFAQLinkLabel.accessibilityTraits = .link
        
        // Dynamic font
        headerLabel.adjustsFontForContentSizeCategory = true
        headerLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 20, maxSize: 30)
        
        userAccountLabel.adjustsFontForContentSizeCategory = true
        userAccountLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 20, maxSize: 30)
        
        helpFAQSectionHeaderLabel.adjustsFontForContentSizeCategory = true
        helpFAQSectionHeaderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 20, maxSize: 30)
        
        birthdateLabel.adjustsFontForContentSizeCategory = true
        birthdateLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: 18)
        birthdateDescLabel.adjustsFontForContentSizeCategory = true
        birthdateDescLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: 20)
        
        residenceLabel.adjustsFontForContentSizeCategory = true
        residenceLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: 20)
        residenceDescLabel.adjustsFontForContentSizeCategory = true
        residenceDescLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: 20)
        
        emailLabel.adjustsFontForContentSizeCategory = true
        emailLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: 18)
        emailDescLabel.adjustsFontForContentSizeCategory = true
        emailDescLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: 20)
        
        passwordLabel.adjustsFontForContentSizeCategory = true
        passwordLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: 20)
        passwordDescLabel.adjustsFontForContentSizeCategory = true
        passwordDescLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: 20)
        
        helpFAQLinkLabel.adjustsFontForContentSizeCategory = true
        helpFAQLinkLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: 20)
        impressumLinkLabel.adjustsFontForContentSizeCategory = true
        impressumLinkLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: 20)
        dataPrivacySettingsLabel.adjustsFontForContentSizeCategory = true
        dataPrivacySettingsLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: 20)
        securityLinkLabel.adjustsFontForContentSizeCategory = true
        securityLinkLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: 20)
        
        accessibilityStatementLabel.adjustsFontForContentSizeCategory = true
        accessibilityStatementLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: 20)
        
        feedbackLabel.adjustsFontForContentSizeCategory = true
        feedbackLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: 20)
        
        softwareLicenseLabel.adjustsFontForContentSizeCategory = true
        softwareLicenseLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: 20)

        logoutBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        logoutBtn.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 18, maxSize: 30)
        
        modeLabel.adjustsFontForContentSizeCategory = true
        modeLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: 20)
        liveModeRadioView.titleLabel.adjustsFontForContentSizeCategory = true
        liveModeRadioView.titleLabel.font = !isPreviewMode ? UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: 20) : UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: 20)
        previewModeRadioView.titleLabel.adjustsFontForContentSizeCategory = true
        previewModeRadioView.titleLabel.font = !isPreviewMode ? UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: 20) : UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: 20)
        
        headerLabel.accessibilityTraits = .header
        headerLabel.accessibilityLabel = "\(SCUtilities.getHeaderStringWith(level: 1)) \(LocalizationKeys.Profile.p001ProfileLabelPersonalData.localized())"
        
        userAccountLabel.accessibilityTraits = .header
        userAccountLabel.accessibilityLabel = "\(SCUtilities.getHeaderStringWith(level: 2)) \(LocalizationKeys.Profile.p001ProfileLabelAccountSettings.localized())"
        
        helpFAQSectionHeaderLabel.accessibilityTraits = .header
        helpFAQSectionHeaderLabel.accessibilityLabel = "\(SCUtilities.getHeaderStringWith(level: 3)) \(LocalizationKeys.Profile.p001ProfileHelpSectionHeader.localized())"
    }

    private func addRefreshToPull(on scrollView: UIScrollView, topYPosition: CGFloat) {
        
        scrollView.refreshControl = self.refreshControl
        
        self.refreshControl.tintColor = UIColor(named: "CLR_PULL_TO_REFRESH")
        self.refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControl.Event.valueChanged)
    }
    
    private func adaptFontSizes() {
       
        // TODO: there must be a better way
        self.headerLabel.adaptFontSize()
        

        self.residenceDescLabel.adaptFontSize()
        self.residenceLabel.adaptFontSize()
        self.birthdateDescLabel.adaptFontSize()
        self.birthdateLabel.adaptFontSize()
        
        self.userAccountLabel.adaptFontSize()
        self.emailDescLabel.adaptFontSize()
        self.emailLabel.adaptFontSize()
        self.passwordDescLabel.adaptFontSize()
        self.passwordLabel.adaptFontSize()
        
        self.impressumLinkLabel.adaptFontSize()
        self.securityLinkLabel.adaptFontSize()
        self.dataPrivacySettingsLabel.adaptFontSize()
        self.feedbackLabel.adaptFontSize()
        self.softwareLicenseLabel.adaptFontSize()
        
        self.modeLabel.adaptFontSize()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                self.refreshImagesForLightDarkMode()
            }
        }
    }

    private func refreshImagesForLightDarkMode(){
        
        if let imageEB = self.userAccountEditButton?.image(for: .normal){
            self.userAccountEditButton?.setImage(imageEB.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!), for: .normal)
        }
        
        if let imagePD = self.personalDataEditButton?.image(for: .normal){
            self.personalDataEditButton?.setImage(imagePD.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!), for: .normal)
        }

        if let imageHelp = self.imgArrowHelpFAQ?.image{
            self.imgArrowHelpFAQ?.image = imageHelp.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!)
        }

        if let imageDP = self.imgArrowDataPrivacy?.image {
            self.imgArrowDataPrivacy?.image = imageDP.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!)
        }

        if let imageDPSettings = self.imgArrowDataPrivacySettings?.image {
            self.imgArrowDataPrivacySettings?.image = imageDPSettings.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!)
        }

        if let imageImp = self.imgArrowImpressum?.image {
            self.imgArrowImpressum?.image = imageImp.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!)
        }

        if let imageAccStmt = self.imgArrowAccessibilityStatement?.image {
            self.imgArrowAccessibilityStatement?.image = imageAccStmt.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!)
        }
        
        if let imageFeedback = self.imgArrowFeedback?.image {
            self.imgArrowFeedback?.image = imageFeedback.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!)
        }
        
        if let imageSoftwareLicense = self.imgArrowSoftwareLicense?.image {
            self.imgArrowSoftwareLicense?.image = imageSoftwareLicense.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!)
        }
        
        if let imageHelp = self.imgHelpFAQ?.image{
            self.imgHelpFAQ?.image = imageHelp.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!)
        }

        if let imageDP = self.imgDataPrivacy?.image {
            self.imgDataPrivacy?.image = imageDP.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!)
        }

        if let imageDPSettings = self.imgDataPrivacySettings?.image {
            self.imgDataPrivacySettings?.image = imageDPSettings.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!)
        }

        if let imageImp = self.imgImpressum?.image {
            self.imgImpressum?.image = imageImp.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!)
        }

        if let imageAccStmt = self.imgAccessibilityStatement?.image {
            self.imgAccessibilityStatement?.image = imageAccStmt.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!)
        }
        
        if let imageFeedback = self.imgFeedback?.image {
            self.imgFeedback?.image = imageFeedback.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!)
        }
        
        if let imageSoftwareLicense = self.imgSoftwareLicense?.image {
            self.imgSoftwareLicense?.image = imageSoftwareLicense.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!)
        }

    }
    
    private func setDescriptionTexts() {
        self.headerLabel.text = LocalizationKeys.Profile.p001ProfileLabelPersonalData.localized()
        
        self.residenceDescLabel.text = LocalizationKeys.Profile.p001ProfileLabelResidence.localized()
        self.birthdateDescLabel.text = LocalizationKeys.Profile.p001ProfileLabelBirthday.localized()
        
        self.userAccountLabel.text = LocalizationKeys.Profile.p001ProfileLabelAccountSettings.localized()
        self.emailDescLabel.text = LocalizationKeys.Profile.p001ProfileLabelEmail.localized()
        self.passwordDescLabel.text = LocalizationKeys.Profile.p001ProfileLabelPassword.localized()
        self.modeLabel.text = LocalizationKeys.AppPreviewUI.p001ProfileLabelMode.localized()

        self.helpFAQSectionHeaderLabel.text = LocalizationKeys.Profile.p001ProfileHelpSectionHeader.localized()
        self.helpFAQLinkLabel.text = LocalizationKeys.Profile.p001ProfileHelpLinkLabel.localized()
        
        self.impressumLinkLabel.text = LocalizationKeys.Profile.p001ProfileBtnImprint.localized()
        self.impressumContainer.accessibilityLabel = LocalizationKeys.Profile.p001ProfileBtnImprint.localized()
        self.securityLinkLabel.text = LocalizationKeys.Profile.p001ProfileLabelDataSecurity.localized()
        self.securityLinkContainer.accessibilityLabel = LocalizationKeys.Profile.p001ProfileLabelDataSecurity.localized()
        self.dataPrivacySettingsLabel.text = LocalizationKeys.Profile.p001ProfileLabelDataSecuritySettings.localized()
        self.dataPrivacySettingsContainer.accessibilityLabel = LocalizationKeys.Profile.p001ProfileLabelDataSecuritySettings.localized()

        self.accessibilityStatementLabel.text = LocalizationKeys.Profile.p001ProfileAccessibilityStmtLinkLabel.localized()
        self.accessibilityStatementContainer.accessibilityLabel = LocalizationKeys.Profile.p001ProfileAccessibilityStmtLinkLabel.localized()
        self.accessibilityStatementContainer.accessibilityHint = LocalizationKeys.Profile.accessibilityCellDblClickHint.localized()
        
        self.feedbackLabel.text = LocalizationKeys.Profile.p001ProfileFeedbackLabel.localized()
        self.feedbackContainer.accessibilityLabel = LocalizationKeys.Profile.p001ProfileFeedbackLabel.localized()
        self.feedbackContainer.accessibilityHint = LocalizationKeys.Profile.accessibilityCellDblClickHint.localized()

        self.softwareLicenseLabel.text = LocalizationKeys.Profile.p001ProfileSoftwareLicenseTitle.localized()
        self.softwareLicenseContainer.accessibilityLabel = LocalizationKeys.Profile.p001ProfileSoftwareLicenseTitle.localized()
        self.softwareLicenseContainer.accessibilityHint = LocalizationKeys.Profile.accessibilityCellDblClickHint.localized()

        self.logoutBtn.setTitle(LocalizationKeys.Profile.p001ProfileBtnLogout.localized(), for: .normal)
        self.logoutBtn.titleLabel?.adaptFontSize()
    }
    
    private func setupAppPreviewUI(_ isCSPUser: Bool, isPreviewMode: Bool) {

        appPreviewModeStackView.isHidden = !isCSPUser ? true : false
        liveModeRadioView.titleLabel.text = LocalizationKeys.AppPreviewUI.p001ProfileLabelModeLive.localized()
        liveModeRadioView.radioToggleImageView.image = !isPreviewMode ? UIImage(named: "radiobox-marked") : UIImage(named: "radiobox-blank")

        previewModeRadioView.titleLabel.text = LocalizationKeys.AppPreviewUI.p001ProfileLabelModePreview.localized()
        previewModeRadioView.radioToggleImageView.image = !isPreviewMode ? UIImage(named: "radiobox-blank") : UIImage(named: "radiobox-marked")
    
        previewModeRadioView.titleLabel.font = UIFont.systemFont(ofSize: previewModeRadioView.titleLabel.font.pointSize, weight: (!isPreviewMode ? .regular : .bold))
        liveModeRadioView.titleLabel.font = UIFont.systemFont(ofSize: liveModeRadioView.titleLabel.font.pointSize, weight: (!isPreviewMode ? .bold : .regular))
    }
    
    func addGestureRecogniserForModeUI() {
        // liveModeRadioView gesture
        let liveModeRadioViewGesture = UITapGestureRecognizer(target: self, action: #selector(liveModeOptionTapped))
        liveModeRadioView.addGestureRecognizer(liveModeRadioViewGesture)
        
        // previewModeRadioView gesture
        let previewModeRadioViewGesture = UITapGestureRecognizer(target: self, action: #selector(previewModeOptionTapped))
        previewModeRadioView.addGestureRecognizer(previewModeRadioViewGesture)
    }
    
    @objc private func liveModeOptionTapped() {
        liveModeRadioView.radioToggleImageView.image = UIImage(named: "radiobox-marked")
        previewModeRadioView.radioToggleImageView.image = UIImage(named: "radiobox-blank")
        liveModeRadioView.titleLabel.font = UIFont.systemFont(ofSize: liveModeRadioView.titleLabel.font.pointSize, weight: .bold)
        previewModeRadioView.titleLabel.font = UIFont.systemFont(ofSize: previewModeRadioView.titleLabel.font.pointSize, weight: .regular)

        liveModeRadioView.isUserInteractionEnabled = true
        isPreviewMode = false
        SCDataUIEvents.postNotification(for: .didUpdateAppPreviewMode)
    }
    
    @objc private func previewModeOptionTapped() {
        previewModeRadioView.radioToggleImageView.image = UIImage(named: "radiobox-marked")
        liveModeRadioView.radioToggleImageView.image = UIImage(named: "radiobox-blank")
        previewModeRadioView.titleLabel.font = UIFont.systemFont(ofSize: previewModeRadioView.titleLabel.font.pointSize, weight: .bold)
        liveModeRadioView.titleLabel.font = UIFont.systemFont(ofSize: liveModeRadioView.titleLabel.font.pointSize, weight: .regular)

        previewModeRadioView.isUserInteractionEnabled = true
        isPreviewMode = true
        SCDataUIEvents.postNotification(for: .didUpdateAppPreviewMode)
    }
    
    /**
     *
     * Action for Buttons and Gestures
     *
     */
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        self.presenter.closeButtonWasPressed()
    }
    
    @IBAction func editUserAccountWasPressed(_ sender: UIButton) {
        self.presenter.editAccountButtonWasPressed()
    }
    
    @IBAction func editPersonalDataWasPressed(_ sender: UIButton) {
        self.presenter.editPersonalDataButtonWasPressed()
    }

    @IBAction func helpFAQBtnWasPressed(_ sender: UIButton) {
        self.presenter.helpFAQWasPressed()
    }

    @IBAction func imprintBtnWasPressed(_ sender: UIButton) {
        sender.preventMultipleTouches()
        self.presenter.imprintButtonWasPressed()
    }
    
    @IBAction func securityBtnWasPressed(_ sender: UIButton) {
        sender.preventMultipleTouches()
        self.presenter.securityButtonWasPressed()
    }

    @IBAction func dataPrivacySettingsBtnWasPressed(_ sender: UIButton) {
        sender.preventMultipleTouches()
        self.presenter.dataPrivacySettingsButtonWasPressed()
    }

    @IBAction func accessibilityStatementWasPressed(_ sender: UIButton) {
        sender.preventMultipleTouches()
        self.presenter.accessibilityStatementButtonWasPressed()
    }
    
    @IBAction func feedbackWasPressed(_ sender: UIButton) {
        sender.preventMultipleTouches()
        self.presenter.feedbackWasPressed()
    }
    
    @IBAction func softwareLicenseWasPressed(_ sender: UIButton) {
        sender.preventMultipleTouches()
        self.presenter.softwareLicenseWasPressed()
    }

    @IBAction func logoutBtnWasPressed(_ sender: Any) {
        // SMARTC-21454 : Ask for confirmation when user presses logout button
        let alert = UIAlertController(title: "dialog_confirm_logout_title".localized(), message: "dialog_confirm_logout_message".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dialog_confirm_logout_btn_cancel".localized(), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "dialog_confirm_logout_btn_yes".localized(), style: .default, handler: { [weak self] (action) in
            // Resetting the preview mode flag on logout and handle the banner display
            isPreviewMode = false
            SCDataUIEvents.postNotification(for: .didUpdateAppPreviewMode)
            self?.presenter.logoutButtonWasPressed()
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.presenter.refreshData()
    }
}


// MARK: - SCProfileDisplaying
extension SCProfileViewController: SCProfileDisplaying {
    
    func setResidenceName(_ residence: String) {
        self.residenceLabel.text = residence
    }
    
    func setBirthDate(_ birthDate: String) {
        self.birthdateLabel.text = birthDate
    }
    
    func setEmail(_ email: String) {
        self.emailLabel.text = email
    }
    
    func setPassword(_ password: String) {
        self.passwordLabel.text = password
    }
    
    func setAppPreviewMode(_ isCSPUser: Bool, isPreviewMode: Bool) {
        setupAppPreviewUI(isCSPUser, isPreviewMode: isPreviewMode)
    }
    
    func dismiss(completion: (() -> Void)?) {
        self.dismiss(animated: true, completion: completion)
    }
    
    func push(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func endRefreshing() {
        self.refreshControl.endRefreshing()
    }
    
    func setLogoutButtonState(_ state : SCCustomButtonState){
        self.logoutBtn.btnState = state
    }

}

// MARK: - UIButton ectension

extension UIButton {
    
    // Call this method to prevent any multiple touches on button
    func preventMultipleTouches() {
        self.isUserInteractionEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.isUserInteractionEnabled = true
        }
    }
}
