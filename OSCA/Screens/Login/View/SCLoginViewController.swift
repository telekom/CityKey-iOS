//
//  SCLoginViewController.swift
//  SmartCity
//
//  Created by Michael on 02.12.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

class SCLoginViewController: UIViewController, UITextFieldDelegate {

    public var presenter: SCLoginPresenting!

    private let keyboardOffsetSpace : CGFloat = 35.0

    var keyboardHeight : CGFloat = 0.0

    @IBOutlet weak var cancelBtn: UIBarButtonItem!
    @IBOutlet weak var infoTextLabel: UILabel!
    @IBOutlet weak var infoTextLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var infoTextLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoTextTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoTextHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var loginBtn: SCCustomButton!
    @IBOutlet weak var rememberLoginBtn: UIButton!
    @IBOutlet weak var rememberLoginLabel: UILabel!
    @IBOutlet weak var recoverLoginLabel: UILabel!
    @IBOutlet weak var registerLabel: UILabel!
    @IBOutlet weak var topImageView: UIImageView!
    
    @IBOutlet weak var eMailTopLabel: UILabel!
    @IBOutlet weak var eMailTextField: UITextField!
    @IBOutlet weak var eMailErrorLabel: UILabel!

    @IBOutlet weak var pwdTopLabel: UILabel!
    @IBOutlet weak var pwdTextField: SCTextfieldWithoutCopy!
    @IBOutlet weak var pwdShowPasswordBtn: UIButton!
    @IBOutlet weak var pwdErrorLabel: UILabel!

    @IBOutlet weak var pwdSeperatorView: UIView!
    @IBOutlet weak var eMailSeperatorView: UIView!

    @IBOutlet weak var eMailErrorWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var pwdErrorWidthConstraint: NSLayoutConstraint!

    private var maxCharCountPWD = 0
    private var maxCharCountEMail = 0
    private var validationStateWidth : CGFloat!

    private var loginLblText = ""

    
    @IBOutlet weak var contenScrollview: UIScrollView!
    
    
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
    
    @IBOutlet weak var imgFeedback: UIImageView!
    @IBOutlet weak var imgHelpFAQ: UIImageView!
    @IBOutlet weak var imgDataPrivacy: UIImageView!
    @IBOutlet weak var imgDataPrivacySettings: UIImageView!
    @IBOutlet weak var imgImpressum: UIImageView!
    @IBOutlet weak var imgAccessibilityStatement: UIImageView!
    @IBOutlet weak var imgSoftwareLicense: UIImageView!
    @IBOutlet weak var citykeyHelpWebsiteBtn: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.shouldNavBarTransparent = false
        self.validationStateWidth = self.eMailErrorWidthConstraint.constant

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification , object: nil)

        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
        
        self.adaptFontSizes()
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        self.setDiscriptionTexts()
        self.handleDynamicTypeChange()
        
        let rememberLoginTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.rememberLoginLblWasPressed))
        self.rememberLoginLabel.addGestureRecognizer(rememberLoginTapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDynamicTypeChange), name: UIContentSizeCategory.didChangeNotification, object: nil)

   }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshNavigationBarStyle()
        self.presenter.viewWillAppear()
    }

    private func refreshImagesForLightDarkMode(){
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

    
    private func setDiscriptionTexts() {
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
        
        
        self.softwareLicenseLabel.text = LocalizationKeys.Profile.p001ProfileSoftwareLicenseTitle.localized()
        self.softwareLicenseContainer.accessibilityLabel = LocalizationKeys.Profile.p001ProfileSoftwareLicenseTitle.localized()

    }
    
    private func adaptFontSizes() {
        self.impressumLinkLabel.adaptFontSize()
        self.securityLinkLabel.adaptFontSize()
        self.dataPrivacySettingsLabel.adaptFontSize()
    }

    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.cancelBtn.accessibilityIdentifier = "btn_close"
        self.loginBtn.accessibilityIdentifier = "btn_logimn"
        self.rememberLoginBtn.accessibilityIdentifier = "btn_remember"
        self.rememberLoginLabel.accessibilityIdentifier = "lbl_remember"
        self.recoverLoginLabel.accessibilityIdentifier = "lbl_recover"
        self.registerLabel.accessibilityIdentifier = "lbl_register"
        self.topImageView.accessibilityIdentifier = "img_top"
        self.eMailTopLabel.accessibilityIdentifier = "lbl_email_top"
        self.eMailTextField.accessibilityIdentifier = "txtfld_email"
        self.eMailErrorLabel.accessibilityIdentifier = "lbl_email:error"
        self.pwdTopLabel.accessibilityIdentifier = "lbl_password_top"
        self.pwdTextField.accessibilityIdentifier = "txtfld_password"
        self.pwdShowPasswordBtn.accessibilityIdentifier = "btn_show_password"
        self.pwdErrorLabel.accessibilityIdentifier = "lbl_password_error"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
        
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
    }
    
    private func setupAccessibility(){
        self.cancelBtn.accessibilityTraits = .button
        self.cancelBtn.accessibilityLabel = "accessibility_btn_cancel".localized()
        self.cancelBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
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
        
        feedbackLabel.adjustsFontForContentSizeCategory = true
        feedbackLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: 20)
        citykeyHelpWebsiteBtn.accessibilityElementsHidden = true
        helpFAQLinkLabel.accessibilityTraits = .link
        setupAccessibilityToKeepMeLoggedIn()
    }
    
    private func setupAccessibilityToKeepMeLoggedIn() {
        rememberLoginBtn.accessibilityElementsHidden = true
        rememberLoginLabel.isAccessibilityElement = true
        rememberLoginLabel.accessibilityValue = "accessibility_checkbox_state_unchecked".localized()
    }
    
    @objc private func handleDynamicTypeChange() {
        // Dynamic font
        eMailTopLabel.adjustsFontForContentSizeCategory = true
        eMailTopLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 15, maxSize: nil)
        eMailErrorLabel.adjustsFontForContentSizeCategory = true
        eMailErrorLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        pwdTopLabel.adjustsFontForContentSizeCategory = true
        pwdTopLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 15, maxSize: nil)
        pwdErrorLabel.adjustsFontForContentSizeCategory = true
        pwdErrorLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        eMailTextField.adjustsFontForContentSizeCategory = true
        eMailTextField.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 20, maxSize: 25)
        pwdTextField.adjustsFontForContentSizeCategory = true
        pwdTextField.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 20, maxSize: 25)
        
        recoverLoginLabel.adjustsFontForContentSizeCategory = true
        recoverLoginLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 14, maxSize: nil)
        rememberLoginLabel.adjustsFontForContentSizeCategory = true
        rememberLoginLabel.font = UIFont.SystemFont.medium.forTextStyle(style: .footnote, size: 14, maxSize: nil)
        registerLabel.adjustsFontForContentSizeCategory = true
        registerLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .caption1, size: 12, maxSize: nil)
        
        helpFAQSectionHeaderLabel.adjustsFontForContentSizeCategory = true
        helpFAQSectionHeaderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 20, maxSize: 30)
        
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
        
        softwareLicenseLabel.adjustsFontForContentSizeCategory = true
        softwareLicenseLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: 20)

        loginBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        loginBtn.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 18, maxSize: 36)
    }

    deinit {
        SCDataUIEvents.discardNotifications(for: self)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                if let rlimage = self.rememberLoginBtn?.image(for: .normal){
                    self.rememberLoginBtn?.setImage(rlimage.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!), for: .normal)
                    self.refreshImagesForLightDarkMode()
                }
                if let spimage = self.pwdShowPasswordBtn?.image(for: .normal){
                    self.pwdShowPasswordBtn?.setImage(spimage.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!), for: .normal)
                }
            }
        }
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue

        self.adjustContentForShowingKeyboard(keyboardFrame: keyboardFrame)
        self.view.setNeedsLayout()
        self.view.setNeedsUpdateConstraints()
    }

    @objc func keyboardWillHide(notification: NSNotification){
        self.adjustContentForHidingKeyboard()
        self.view.setNeedsLayout()
        self.view.setNeedsUpdateConstraints()
    }
    
    private func adjustContentForShowingKeyboard(keyboardFrame : CGRect) {
        let height = keyboardFrame.height + keyboardOffsetSpace
        self.keyboardHeight = height
        
        self.contenScrollview?.contentInset.bottom = 280
        self.contenScrollview.setNeedsLayout()
        self.contenScrollview.setNeedsUpdateConstraints()
    }
    
    private func adjustContentForHidingKeyboard() {
        self.contenScrollview?.contentInset.bottom = 0.0
        self.contenScrollview.setNeedsLayout()
        self.contenScrollview.setNeedsUpdateConstraints()
    }
    

    /**
     *
     * Method to get referenced of the embedded viewController
     *
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        switch segue.destination {

        case let legalInfoLink as SCSmallLegalInfoLinkVC:
            legalInfoLink.linkStyle = .dark
            legalInfoLink.linkDelegate = self
            break
        default:
            break
        }
    }



    //  UITextFieldDelegate methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // when enterinmg as field, reset the error messages
        if (textField == self.eMailTextField){
            self.presenter.eMailFieldDidBeginEditing()
        } else {
            self.presenter.passwordFieldDidBeginEditing()
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if (string == " " && (textField == self.pwdTextField || textField == self.eMailTextField)) { return false }
        
        var maxCharCount = self.maxCharCountEMail
        if textField == self.pwdTextField {
             maxCharCount = self.maxCharCountPWD
        }
        // here we check only the max length
        guard let text = textField.text else { return true }
        let count = text.count + string.count - range.length
        return count <= maxCharCount
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()

        if (textField == self.eMailTextField){
            if let nextComponent = self.pwdTextField {
                nextComponent.becomeFirstResponder()
            }
        }
        return true

    }

    // TextField Actions
    @IBAction func textfieldEditingChanged(_ sender: Any) {
        self.texfieldDidChange(sender as! UITextField)
    }

    @IBAction func textfieldEditingBegin(_ sender: Any) {
        self.texfieldDidBeginEditing(sender as! UITextField)
    }

    @IBAction func textfieldEditingEnd(_ sender: Any) {
    }

    private func texfieldDidChange(_ textField: UITextField){
        if (textField == self.eMailTextField){
            self.presenter.eMailFieldDidChange()
        } else {
            self.presenter.passwordFieldDidChange()
        }
    
    }

    private func texfieldDidBeginEditing(_ textField: UITextField){
        if (textField == self.eMailTextField){
            self.presenter.eMailFieldDidBeginEditing()
        } else {
            self.presenter.passwordFieldDidBeginEditing()
        }
        
    }
    
    // MARK: - Validation
    
    @IBAction func cancelBtnWasPressed(_ sender: Any) {
        self.presenter.cancelWasPressed()
    }
    

    //
    // Button and Taps Targets
    //

    @objc func registerLblWasPressed() {
        self.presenter.registerWasPressed()
    }

    @objc func recoverLblWasPressed() {
        self.presenter.recoverPwdWasPressed()
    }
    
    @objc func rememberLoginLblWasPressed() {
        self.presenter.rememberLoginWasPressed()
        rememberLoginLabel.accessibilityValue = presenter.isLoginRemembered() ? "accessibility_checkbox_state_checked".localized() : "accessibility_checkbox_state_unchecked".localized()
    }

    @IBAction func rememberLoginBtnWasPressed(_ sender: Any) {
        self.presenter.rememberLoginWasPressed()
    }

    @IBAction func pedShowPasswordBtnWasPressed(_ sender: Any) {
        self.presenter.pwdShowPasswordWasPressed()
    }

    @IBAction func loginBtnWasPressed(_ sender: Any) {
        if !presenter.isLoginRemembered() {
            let alert = UIAlertController(title: "l_001_login_kmli_dialog_title".localized(), message: "l_001_login_kmli_dialog_message".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "negative_button_dialog".localized(), style: .default, handler: { [weak self] (action) in
                self?.presenter.loginWasPressed()
            }))
            alert.addAction(UIAlertAction(title: "dialog_confirm_logout_btn_yes".localized(), style: .default, handler: { [weak self] (action) in
                self?.presenter.rememberLoginWasPressed()
                self?.presenter.loginWasPressed()
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.presenter.loginWasPressed()
        }
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
        self.presenter.softwareLicensekWasPressed()
    }
}

extension SCLoginViewController: SCLoginDisplaying {

    func setupNavigationBar(title: String, backTitle: String){
//        self.topImageView.image = self.topImageView.image?.tintedHeaderImage(tintColor: UIColor(named: "CLR_OSCA_BLUE")!)
        self.navigationItem.title = title
        self.navigationItem.backBarButtonItem?.title = ""

    }

    func setupLoginBtn(title: String){
        // Customize login button
        self.loginBtn.customizeBlueStyle()
        self.loginBtn.titleLabel?.adaptFontSize()
        self.loginBtn.setTitle(title, for: .normal)
        self.loginLblText = title
        
    }

    func setupRememberLoginBtn(title: String){
        self.rememberLoginLabel.adaptFontSize();
        self.rememberLoginLabel.text = title
    }

    func setupRegisterBtn(title: String, linkTitle: String){
        //
        // REGISTER LABEL WITH TAP
        //
        self.registerLabel.adaptFontSize();
        let registerString = title + " " + linkTitle
        let attributedString = NSMutableAttributedString(string: registerString)
        _ = attributedString.setTextColor(textToFind:linkTitle, color: UIColor(named: "CLR_OSCA_BLUE")!)
        self.registerLabel.attributedText = attributedString
        self.registerLabel.isUserInteractionEnabled = true
        
        let registerTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.registerLblWasPressed))
        registerLabel.addGestureRecognizer(registerTapGesture)
    }

    func setupRecoverLoginBtn(title: String){
        //
        // RECOVER LABEL WITH TAP
        //
        self.recoverLoginLabel.adaptFontSize();
        let recoverAttrString = NSMutableAttributedString(string: title)
        _ = recoverAttrString.setTextColor(textToFind:title, color: UIColor(named: "CLR_OSCA_BLUE")!)
        self.recoverLoginLabel.attributedText = recoverAttrString
        self.recoverLoginLabel.isUserInteractionEnabled = true
        
        let recoverTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.recoverLblWasPressed))
        recoverLoginLabel.addGestureRecognizer(recoverTapGesture)
    }

    func setupEMailField(title: String){
        let fontSize : CGFloat = self.eMailTextField.font?.pointSize ?? 0.0
        self.eMailTextField.textColor = UIColor(named: "CLR_LABEL_TEXT_BLACK")!
        self.eMailTopLabel.textColor = UIColor(named: "CLR_LABEL_TEXT_BLACK")!
        
        self.eMailTextField.keyboardType = .emailAddress
        self.eMailTextField.textContentType = .username
        self.eMailTextField.delegate = self
        self.eMailErrorLabel.adaptFontSize()
        self.hideEMailError()
        self.eMailTopLabel.adaptFontSize()
        self.eMailTopLabel.text = title
        self.eMailTopLabel.textColor = UIColor(named: "CLR_LABEL_TEXT_GRAY_GRAY")!
        self.eMailTextField.attributedPlaceholder = NSAttributedString(string: title, attributes: [
            .foregroundColor: UIColor.lightGray,
            .font: UIFont.boldSystemFont(ofSize: fontSize - 3.0)
            ])
    }

    func setupPasswordField(title: String){
        let fontSize : CGFloat = self.pwdTextField.font?.pointSize ?? 0.0
        
        self.pwdTextField.textColor = UIColor(named: "CLR_LABEL_TEXT_BLACK")!
        
        self.pwdTextField.keyboardType = .asciiCapable
        self.pwdTextField.isSecureTextEntry = true
        self.pwdTextField.textContentType = .password
        self.pwdTextField.delegate = self
        self.pwdErrorLabel.adaptFontSize()
        self.hidePWDError()
        self.pwdTopLabel.adaptFontSize()
        self.pwdTopLabel.textColor = UIColor(named: "CLR_LABEL_TEXT_GRAY_GRAY")!
        self.pwdTopLabel.text = title
        self.pwdTextField.attributedPlaceholder = NSAttributedString(string: title, attributes: [
            .foregroundColor: UIColor.lightGray,
            .font: UIFont.boldSystemFont(ofSize: fontSize - 3.0)
            ])
    }

    func refreshTopPlaceholderLabel(){
        self.pwdTopLabel.isHidden = self.pwdTextField.text?.isEmpty ?? true
        self.eMailTopLabel.isHidden = self.eMailTextField.text?.isEmpty ?? true
    }
    
    func showPWDError(message: String){
        self.pwdErrorLabel.isHidden = false
        self.pwdErrorLabel.text = message
        self.pwdErrorLabel.textColor = UIColor(named: "CLR_LABEL_TEXT_RED")!
        self.pwdSeperatorView.backgroundColor = UIColor(named: "CLR_LABEL_TEXT_RED")!
        self.pwdErrorWidthConstraint.constant = self.validationStateWidth
    }
    
    func hidePWDError(){
        if self.pwdErrorLabel.isHidden == false {
            self.pwdErrorLabel.isHidden = true
            self.pwdSeperatorView.backgroundColor = UIColor(named: "CLR_INPUT")!
            self.pwdErrorWidthConstraint.constant = 0.0
        }
    }
    
    func showEMailError(message: String){
        self.eMailErrorLabel.isHidden = false
        self.eMailErrorLabel.text = message
        self.eMailErrorLabel.textColor = UIColor(named: "CLR_LABEL_TEXT_RED")!
        self.eMailSeperatorView.backgroundColor = UIColor(named: "CLR_LABEL_TEXT_RED")!
        self.eMailErrorWidthConstraint.constant = self.validationStateWidth
    }
    
    func hideEMailError(){
        if eMailErrorLabel.isHidden == false {
            self.eMailErrorLabel.isHidden = true
            self.eMailSeperatorView.backgroundColor = UIColor(named: "CLR_INPUT")!
            self.eMailErrorWidthConstraint.constant = 0.0
        }
    }

    func showInfoText(message: String) {
        infoTextLabel.adjustsFontForContentSizeCategory = true
        infoTextLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 14, maxSize: nil)
        
        self.infoTextLabel.text = message
        let labelWidth = self.view.bounds.width - self.infoTextTrailingConstraint.constant - self.infoTextLeadingConstraint.constant
        let estimatedLabelHeight = message.estimatedHeight(withConstrainedWidth: labelWidth, font: self.infoTextLabel.font)
        self.infoTextLabelHeight.constant = estimatedLabelHeight
        self.infoTextHeightConstraint.constant = estimatedLabelHeight + 42
        self.infoTextLabel.setNeedsLayout()
        self.view.setNeedsLayout()
    }

    func hideInfoText(){
        self.infoTextHeightConstraint.constant = 0.0
        self.view.setNeedsLayout()
    }

    func showPasswordSelected(_ selected: Bool){
        if selected {
            self.pwdShowPasswordBtn?.setImage(UIImage(named: "icon_showpass_selected")?.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!), for: .normal)
            self.pwdTextField?.isSecureTextEntry = false
        } else {
            self.pwdShowPasswordBtn?.setImage(UIImage(named: "icon_showpass_unselected")?.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!), for: .normal)
            self.pwdTextField?.isSecureTextEntry = true
        }
    }
    
    func showRememberLoginSelected(_ selected: Bool){
        if selected {
            self.rememberLoginBtn?.setImage(UIImage(named: "checkbox_selected")?.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!), for: .normal)
        } else {
            self.rememberLoginBtn?.setImage(UIImage(named: "checkbox_unselected")?.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!), for: .normal)
        }
    }

    func setLoginButtonState(_ state : SCCustomButtonState){
        self.loginBtn.btnState = state
    }

    func loginButtonState() -> SCCustomButtonState{
        return self.loginBtn.btnState
    }

    func eMailFieldContent() -> String?{
        return self.eMailTextField.text!.trimmingCharacters(in: .whitespaces)
    }

    func pwdFieldContent() -> String?{
        return self.pwdTextField.text!.trimmingCharacters(in: .whitespaces)
    }
    
    func present(viewController: UIViewController) {
        self.present(viewController, animated: true)
    }

    func presentOnTop(viewController: UIViewController, completion: (() -> Void)? = nil) {
        SCUtilities.topViewController().present(viewController, animated: true, completion: completion)
    }

    func push(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func navigationController() -> UINavigationController?{
        return self.navigationController
    }
    
    func passwordFieldMaxLenght(_ lenght : Int) {
        self.maxCharCountPWD = lenght

    }

    func eMailFieldMaxLenght(_ lenght : Int) {
        self.maxCharCountEMail = lenght
        
    }
}

extension SCLoginViewController: SCSmallLegalInfoLinkVCDelegate {
    func impressumButtonWasPressed() {
      //  self.presenter.impressumButtonWasPressed()
    }
    
    func dataPrivacyButtonWasPressed() {
      //  self.presenter.dataPrivacyButtonWasPressed()
    }
    
    
}
