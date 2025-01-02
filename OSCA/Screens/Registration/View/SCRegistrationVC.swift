//
//  SCRegistrationVC.swift
//  SmartCity
//
//  Created by Michael on 06.03.19.
//  Copyright © 2019 Michael. All rights reserved.
//

import UIKit


class SCRegistrationVC: UIViewController, SCTextfieldComponentDelegate {
    
    public var presenter: SCRegistrationPresenting!
    
    private let keyboardOffsetSpace : CGFloat = 35.0
    var keyboardHeight : CGFloat = 0.0
    
    @IBOutlet weak var closeBtn: UIBarButtonItem!
    @IBOutlet weak var contentScrollview: UIScrollView!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var submitBtn: SCCustomButton!

    @IBOutlet weak var privacyValidationStateLabel: UILabel!
    @IBOutlet weak var privacyValidationStateView: UIImageView!
    @IBOutlet weak var privacyBtn: UIButton!
    @IBOutlet weak var privacyLabel: SCLabelWithLinks!

    @IBOutlet weak var privacyView: UIView!

    var txtfldEmail : SCTextfieldComponent?
    var txtfldPwd1 : SCTextfieldComponent?
    var txtfldPwd2 : SCTextfieldComponent?
    var txtfldBirthdate : SCTextfieldComponent?
    var txtfldPostalCode : SCTextfieldComponent?
    
    var pwdCheckViewController : SCRegistrationPWDCheckVC?
    var activeComponent: SCTextfieldComponent?
    
    @IBOutlet weak var pwdCheckVCHeightConstraint: NSLayoutConstraint!
    
    var pwdCheckVCOpenedHeight: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shouldNavBarTransparent = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification , object: nil)
 
        self.setupAccessibilityIDs()
        self.setupAccessibility()

        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()

        let privacyTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.privacyViewWasPressed))
        self.privacyView.addGestureRecognizer(privacyTapGesture)
//        privacyTapGesture.cancelsTouchesInView = false
        
        self.handleDynamicTypeChange()
                
        NotificationCenter.default.addObserver(self, selector: #selector(handleDynamicTypeChange), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.pwdCheckVCHeightConstraint.constant =  (self.pwdCheckViewController?.view.intrinsicContentSize.height)!
        self.view.setNeedsLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshNavigationBarStyle()
    }

    deinit {
        SCDataUIEvents.discardNotifications(for: self)
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.closeBtn.accessibilityIdentifier = "close_btn"
        self.topImageView.accessibilityIdentifier = "img_top"
        self.submitBtn.accessibilityIdentifier = "btn_submit"
        self.privacyValidationStateLabel.accessibilityIdentifier = "lbl_privacy_validation_state"
        self.privacyValidationStateView.accessibilityIdentifier = "lbl_privacy_validation_state"
        self.privacyBtn.accessibilityIdentifier = "btn_privacy"
        self.privacyLabel.accessibilityIdentifier = "btn_privacy"
        
        self.txtfldEmail?.accessibilityIdentifier = "tf_email"
        self.txtfldPwd1?.accessibilityIdentifier = "tf_pwd1"
        self.txtfldPwd2?.accessibilityIdentifier = "tf_pwd2"
        self.txtfldBirthdate?.accessibilityIdentifier = "tf_birthdate"
        self.txtfldPostalCode?.accessibilityIdentifier = "tf_postalcode"
        
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
        
        self.privacyView.accessibilityIdentifier = "view_privacy"
    }
    
    private func setupAccessibility(){
        self.closeBtn.accessibilityTraits = .button
        self.closeBtn.accessibilityLabel = "accessibility_btn_close".localized()
        self.closeBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        let passwordStrengthMsg = "r_001_registration_hint_password_strength".localized() + ": " +  "r_001_registration_p_005_profile_password_strength_hint_min_8_chars".localized() + ", " + "r_001_registration_p_005_profile_password_strength_error_min_1_symbol".localized() + ", " + "r_001_registration_p_005_profile_password_strength_error_min_1_digit".localized()
        UIAccessibility.post(notification: .announcement, argument: passwordStrengthMsg)

        self.privacyBtn.isAccessibilityElement = true
        self.privacyLabel.isAccessibilityElement = true
        self.privacyView.accessibilityElements = [self.privacyBtn!, self.privacyLabel!]
        self.privacyView.shouldGroupAccessibilityChildren = true
        
        //Dynamic font
        privacyLabel.adjustsFontForContentSizeCategory = true
        privacyLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .caption1, size: 12, maxSize: nil)
        privacyValidationStateLabel.adjustsFontForContentSizeCategory = true
        privacyValidationStateLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: nil)
    }

    @objc private func handleDynamicTypeChange() {
        // Dynamic font
        
        // Setup Dynamic font for Email
        self.txtfldEmail?.textField.adjustsFontForContentSizeCategory = true
        self.txtfldEmail?.textField.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 20, maxSize: 25)
        self.txtfldEmail?.placeholderLabel.adjustsFontForContentSizeCategory = true
        self.txtfldEmail?.placeholderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 15, maxSize: 25)
        self.txtfldEmail?.errorLabel.adjustsFontForContentSizeCategory = true
        self.txtfldEmail?.errorLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        
        // Setup Dynamic font for Pwd1
        self.txtfldPwd1?.textField.adjustsFontForContentSizeCategory = true
        self.txtfldPwd1?.textField.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 20, maxSize: 25)
        self.txtfldPwd1?.placeholderLabel.adjustsFontForContentSizeCategory = true
        self.txtfldPwd1?.placeholderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 15, maxSize: 25)
        self.txtfldPwd1?.errorLabel.adjustsFontForContentSizeCategory = true
        self.txtfldPwd1?.errorLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        
        // Setup Dynamic font for Pwd2
        self.txtfldPwd2?.textField.adjustsFontForContentSizeCategory = true
        self.txtfldPwd2?.textField.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 20, maxSize: 25)
        self.txtfldPwd2?.placeholderLabel.adjustsFontForContentSizeCategory = true
        self.txtfldPwd2?.placeholderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 15, maxSize: 25)
        self.txtfldPwd2?.errorLabel.adjustsFontForContentSizeCategory = true
        self.txtfldPwd2?.errorLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        
        // Setup Dynamic font for Birthdate
        self.txtfldBirthdate?.textField.adjustsFontForContentSizeCategory = true
        self.txtfldBirthdate?.textField.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 20, maxSize: 24)
        self.txtfldBirthdate?.placeholderLabel.adjustsFontForContentSizeCategory = true
        self.txtfldBirthdate?.placeholderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 15, maxSize: 25)
        self.txtfldBirthdate?.errorLabel.adjustsFontForContentSizeCategory = true
        self.txtfldBirthdate?.errorLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        
        // Setup Dynamic font for PostalCode
        self.txtfldPostalCode?.textField.adjustsFontForContentSizeCategory = true
        self.txtfldPostalCode?.textField.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 20, maxSize: 25)
        self.txtfldPostalCode?.placeholderLabel.adjustsFontForContentSizeCategory = true
        self.txtfldPostalCode?.placeholderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 15, maxSize: 25)
        self.txtfldPostalCode?.errorLabel.adjustsFontForContentSizeCategory = true
        self.txtfldPostalCode?.errorLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: nil)

        // Setup Dynamic font for Privacy info text
        privacyValidationStateLabel.adjustsFontForContentSizeCategory = true
        privacyValidationStateLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        
        privacyLabel.adjustsFontForContentSizeCategory = true
        privacyLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        
        self.pwdCheckViewController?.pwdCheckTopLabel.adjustsFontForContentSizeCategory = true
        self.pwdCheckViewController?.pwdCheckTopLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: 20)
        self.pwdCheckViewController?.pwdCheckDetailLabel.adjustsFontForContentSizeCategory = true
        self.pwdCheckViewController?.pwdCheckDetailLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: 20)
        
        self.submitBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        self.submitBtn.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 18, maxSize: 30)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                if let privacyimage = self.privacyBtn?.image(for: .normal){
                    self.privacyBtn?.setImage(privacyimage.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!), for: .normal)
                }
            }
        }
    }
    
    /**
     *
     * Handle Keyboard
     *
     */
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        
        self.adjustContentForShowingKeyboard(keyboardFrame: keyboardFrame)
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        //self.adjustContentForHidingKeyboard()
    }
    
    private func adjustContentForShowingKeyboard(keyboardFrame : CGRect) {
        let height = keyboardFrame.height + keyboardOffsetSpace
        self.keyboardHeight = height
        
        self.contentScrollview?.contentInset.bottom = height
        
        if self.activeComponent != nil {
            self.scrollComponentToVisibleArea(component: self.activeComponent!)
        }
    }
    
    private func adjustContentForHidingKeyboard() {
        self.contentScrollview?.contentInset.bottom = 0.0
    }
    
    /**
     *
     * Method to scroll to a component
     */
    
    func scrollComponentToVisibleArea(component: SCTextfieldComponent) {
        var navBarHeight : CGFloat = 0.0
        var aRect : CGRect = self.contentScrollview.bounds
        
        if let navigationController = self.navigationController {
            navBarHeight = navigationController.navigationBar.frame.size.height + navigationController.navigationBar.frame.origin.y
        }
        
        aRect.size.height -= self.keyboardHeight
        aRect.size.height += navBarHeight
        let fieldPoint = CGPoint(x: 0.0 , y: component.textfieldFrame().origin.y + component.textfieldFrame().size.height)
        if !(aRect.contains(fieldPoint))
        {
            self.contentScrollview.setContentOffset(CGPoint(x:0, y:component.textfieldFrame().origin.y - aRect.size.height + keyboardOffsetSpace + component.textfieldFrame().size.height  ), animated: true)
            
        }
    }
    
    
    /**
     *
     * Method to get referenced of the embedded viewController
     *
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.destination {
            
        case let textfield as SCTextfieldComponent:
            textfield.delegate = self
            
            self.txtfldEmail = self.presenter.configureField(textfield, identifier: segue.identifier, type: .email, autocapitalizationType: .none) as? SCTextfieldComponent ?? self.txtfldEmail
            self.txtfldPwd1 = self.presenter.configureField(textfield, identifier: segue.identifier, type: .pwd1, autocapitalizationType: .none) as? SCTextfieldComponent ?? self.txtfldPwd1
            self.txtfldPwd2 = self.presenter.configureField(textfield, identifier: segue.identifier, type: .pwd2, autocapitalizationType: .none) as? SCTextfieldComponent ?? self.txtfldPwd2
            self.txtfldBirthdate = self.presenter.configureField(textfield, identifier: segue.identifier, type: .birthdate, autocapitalizationType: .none) as? SCTextfieldComponent ?? self.txtfldBirthdate
            self.txtfldPostalCode = self.presenter.configureField(textfield, identifier: segue.identifier, type: .postalCode, autocapitalizationType: .none) as? SCTextfieldComponent ?? self.txtfldPostalCode
            
        case let pwdVC as SCRegistrationPWDCheckVC:
            self.pwdCheckViewController = pwdVC
            //get the  height of the view and store it
            self.pwdCheckVCOpenedHeight = self.pwdCheckVCHeightConstraint.constant
            // then set it to 0 to hide the view
            self.pwdCheckVCHeightConstraint.constant = 0.0
        default:
            break
        }
    }
    
    @objc func privacyViewWasPressed() {
        self.presenter.privacyWasPressed()
    }
    
    @IBAction func submitBtnWasPressed(_ sender: Any) {
        self.presenter.submitWasPressed()
    }
    
    @IBAction func privacyBtnWasPressed(_ sender: Any) {
        self.presenter.privacyWasPressed()
    }
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        self.presenter.closeWasPressed()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func textFieldComponentShouldReturn(component: SCTextfieldComponent) -> Bool {
        component.resignResponder()
        
        if (component == self.txtfldEmail){
            if let nextComponent = self.txtfldPwd1 {
                self.scrollComponentToVisibleArea(component: nextComponent)
                nextComponent.becomeResponder()
            }
        }
        if (component == self.txtfldPwd1){
            if let nextComponent : SCTextfieldComponent = self.txtfldPwd2?.isEnabled() ?? false ? self.txtfldPwd2  : self.txtfldBirthdate  {
                self.scrollComponentToVisibleArea(component: nextComponent)
                nextComponent.becomeResponder()
            }
        }
        if (component == self.txtfldPwd2){
            if let nextComponent = self.txtfldBirthdate {
                self.scrollComponentToVisibleArea(component: nextComponent)
                nextComponent.becomeResponder()
            }
        }
        if (component == self.txtfldBirthdate){
            if let nextComponent = self.txtfldPostalCode {
                self.scrollComponentToVisibleArea(component: nextComponent)
                nextComponent.becomeResponder()
            }
        }
        return true
    }
    
    func textFieldComponentEditingBegin(component: SCTextfieldComponent) {
        
        self.activeComponent = component
        self.scrollComponentToVisibleArea(component:component)
        
        if component == self.txtfldBirthdate {
            txtfldBirthdate?.resignResponder()
            presenter.textFieldDateOfBirthTapped()
        }
        
        // we show the password check controller when entering the password field
        if component == self.txtfldPwd1 {
            UIView.animate(withDuration: 0.5, delay: 0.0,
                           options: [.curveEaseInOut], animations: {
                            self.pwdCheckVCHeightConstraint.constant = self.pwdCheckVCOpenedHeight + self.pwdCheckViewController!.pwdCheckDetailLabelHeight.constant
                            self.view.layoutIfNeeded()
            }, completion: nil)
        }
        
    }
    
    
    func textFieldComponentEditingEnd(component: SCTextfieldComponent) {
        if component == self.txtfldPwd1 {
            UIView.animate(withDuration: 0.5, delay: 0.0,
                           options: [.curveEaseInOut], animations: {
                            self.pwdCheckVCHeightConstraint.constant = 0.0
                            self.view.layoutIfNeeded()
            }, completion: nil)
        }
        
        self.presenter.txtFieldEditingDidEnd(value : component.text ?? "", inputField: self.registrationField(for: component)!, textFieldType: component.textfieldType)
    }
    
    func textFieldComponentDidChange(component: SCTextfieldComponent) {
        self.presenter.textFieldComponentDidChange(for: registrationField(for: component)!)
    }
    
    func datePickerDoneWasPressed(){
        _  = textFieldComponentShouldReturn(component: self.txtfldBirthdate!)
    }
    
    /// below callbacks from SCTextFieldComponent are removed for SMARTC-17956 , clear button replaces the prev and next arrow buttons on the toolbar
    /*
    func datePickerNextWasPressed(){
        _ = textFieldComponentShouldReturn(component: self.txtfldBirthdate!)
    }
    
    func datePickerPreviousWasPressed(){
        if let previousComponent = self.txtfldPwd2 {
            self.scrollComponentToVisibleArea(component: previousComponent)
            previousComponent.becomeResponder()
        }
    }
   */
    
    private func textField(for inputField: SCRegistrationInputFields) -> SCTextfieldComponent?{
        switch inputField {
        case .email:
            return self.txtfldEmail
        case .pwd1:
            return self.txtfldPwd1
        case .pwd2:
            return self.txtfldPwd2
        case .birthdate:
            return self.txtfldBirthdate
        case .postalCode:
            return self.txtfldPostalCode
        }
        
    }
    private func registrationField(for inputField: SCTextfieldComponent? ) ->  SCRegistrationInputFields?{
        switch inputField {
        case self.txtfldEmail:
            return .email
        case self.txtfldPwd1:
            return.pwd1
        case self.txtfldPwd2:
            return .pwd2
        case self.txtfldBirthdate:
            return .birthdate
        case self.txtfldPostalCode:
            return .postalCode
        default:
            return nil
        }
        
    }
}

extension SCRegistrationVC: SCRegistrationDisplaying {
    func overlay(viewController: UIViewController) {
        // TODO: this is the old way, not ready for device rotation and NO autolayout here ...
        self.addChild(viewController)
        self.view.addSubview(viewController.view)
        viewController.view.frame = self.contentScrollview.frame
    }
    
    func push(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func present(viewController: UIViewController) {
        self.present(viewController, animated: true)
    }

    func setupNavigationBar(title: String, backTitle: String){
        self.navigationItem.title = title
        self.navigationItem.backBarButtonItem?.title = ""
    }
    
    func setupUI(title: String){
        self.submitBtn.customizeBlueStyle()
        self.submitBtn.titleLabel?.adaptFontSize()
        self.submitBtn.setTitle(title, for: .normal)
        
        self.privacyLabel.adaptFontSize();
        
        self.privacyValidationStateView.image = nil
        self.privacyValidationStateLabel.text = ""
        self.configureLinksInLabels()
        self.hideKeyboardWhenTappedAround()
        
        self.privacyBtn?.setImage(UIImage(named: "checkbox_unselected")?.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!), for: .normal)
    }
        
    func setDisallowedCharacterForPassword(_ disallowedChars: String) {
        self.txtfldPwd1?.disallowedCharacters = disallowedChars
        self.txtfldPwd2?.disallowedCharacters = disallowedChars
    }
    
    func setDisallowedCharacterForEMail(_ disallowedChars: String) {
        self.txtfldEmail?.disallowedCharacters = disallowedChars
    }

    func dismissView(animated flag: Bool, completion: (() -> Void)? = nil){
        self.navigationController?.dismiss(animated: flag, completion: completion)
    }
    
    func setSubmitButtonState(_ state : SCCustomButtonState){
        self.submitBtn.btnState = state
    }
    
    func getValue(for inputField: SCRegistrationInputFields) -> String?{
        return self.textField(for: inputField)!.text
    }
    
    func getFieldType(for inputField: SCRegistrationInputFields) -> SCTextfieldComponentType{
        return self.textField(for: inputField)!.textfieldType
    }
    
    func getValidationState(for inputField: SCRegistrationInputFields) -> SCTextfieldValidationState{
        return self.textField(for: inputField)!.validationState
    }
    
    func hideError(for inputField: SCRegistrationInputFields){
        self.textField(for: inputField)?.hideError()
        self.textField(for: inputField)?.validationState = .unmarked
    }
    func setEnable(for inputField: SCRegistrationInputFields,enabled : Bool ){
        self.textField(for: inputField)?.setEnabled(enabled)
    }
    
    func showError(for inputField: SCRegistrationInputFields, text: String){
        self.textField(for: inputField)?.showError(message: text)
        self.updateValidationState(for: inputField, state: .wrong)
    }

    func scrollContent(to inputField: SCRegistrationInputFields){
        if let txtFld = self.textField(for: inputField){
            self.scrollComponentToVisibleArea(component: txtFld)
        }
    }

    func showMessagse(for inputField: SCRegistrationInputFields, text: String, color: UIColor){
        self.textField(for: inputField)?.show(message: text, color: color)
    }
    
    func deleteContent(for inputField: SCRegistrationInputFields){
        self.textField(for: inputField)?.deleteContent()
    }
    
    func updateValidationState(for inputField: SCRegistrationInputFields, state: SCTextfieldValidationState){
        self.textField(for: inputField)?.validationState = state
        
        if (inputField == .pwd1 || inputField == .pwd2) && state == .ok{
             self.textField(for: inputField)?.setLineColor(UIColor(named: "CLR_LABEL_TEXT_GREEN")!)
        }
    }
    
    func updatePrivacyValidationState(_ accepted : Bool, showErrorInfoWhenNotAccepted: Bool){
        self.privacyValidationStateLabel.text = nil
        self.privacyValidationStateView.image = nil
        if !accepted {
            if showErrorInfoWhenNotAccepted{
                self.privacyValidationStateLabel.text = "r_001_registration_label_consent_required".localized()
                self.privacyValidationStateLabel.textColor = UIColor(named: "CLR_LABEL_TEXT_RED")!
                self.privacyValidationStateView.image = UIImage(named: "icon_val_error")
                self.privacyValidationStateLabel.accessibilityElementsHidden = false
                self.privacyValidationStateLabel.accessibilityTraits = .staticText
                self.privacyValidationStateLabel.accessibilityLabel = "r_001_registration_label_consent_required".localized()
                self.privacyValidationStateLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
            }
        } else {
            self.privacyValidationStateView.image = UIImage(named: "icon_val_ok")
            self.privacyValidationStateLabel.accessibilityElementsHidden = true
        }
    }
    
    
    func updatePrivacyCheckbox(accepted: Bool) {
        
        self.privacyValidationStateLabel.text = nil
        self.privacyValidationStateView.image = nil
        
        if accepted {
            self.privacyBtn?.setImage(UIImage(named: "checkbox_selected")?.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!), for: .normal)
        } else {
            self.privacyBtn?.setImage(UIImage(named: "checkbox_unselected")?.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!), for: .normal)
        }
    }
    
    func updatePWDChecker(charCount: Int,  minCharReached: Bool, symbolAvailable: Bool, digitAvailable: Bool){
        self.pwdCheckViewController?.refreshWith(charCount: charCount, minCharReached: minCharReached, symbolAvailable: symbolAvailable, digitAvailable: digitAvailable)
    }
    
    func updateDobText(dob: String?) {
        self.txtfldBirthdate?.text = dob
        txtfldBirthdate?.placeholderLabel.isHidden = false
        txtfldPostalCode?.becomeResponder()
        
    }
}

