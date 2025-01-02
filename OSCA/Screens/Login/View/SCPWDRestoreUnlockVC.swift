//
//  SCPWDRecoveryVC.swift
//  SmartCity
//
//  Created by Michael on 04.04.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

enum SCPWDRestoreUnlockInputFields {
    case email
    case pwd1
    case pwd2
}


class SCPWDRestoreUnlockVC: UIViewController {
    
    public var presenter: SCPWDRestoreUnlockPresenting!

    @IBOutlet weak var cancelBtn: UIBarButtonItem!
    @IBOutlet weak var contentScrollview: UIScrollView!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var detailLabel: SCTopAlignLabel!
    @IBOutlet weak var recoverBtn: SCCustomButton!
    @IBOutlet weak var pwdCheckVCHeightConstraint: NSLayoutConstraint!
    
    private let keyboardOffsetSpace : CGFloat = 35.0
    private var keyboardHeight : CGFloat = 0.0
    
    internal var txtfldEmail : SCTextfieldComponent?
    internal var defaultEMail = ""
    internal var txtfldPwd1 : SCTextfieldComponent?
    internal var txtfldPwd2 : SCTextfieldComponent?

    var pwdCheckViewController : SCRegistrationPWDCheckVC?
    var activeComponent: SCTextfieldComponent?
    var pwdCheckVCOpenedHeight: CGFloat = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.shouldNavBarTransparent = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification , object: nil)
        
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        
        self.handleDynamicTypeChange()
                
        NotificationCenter.default.addObserver(self, selector: #selector(handleDynamicTypeChange), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }

    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.cancelBtn.accessibilityIdentifier = "btn_close"
        self.topImageView.accessibilityIdentifier = "img_top"
        self.iconImageView.accessibilityIdentifier = "img_icon"
        self.detailLabel.accessibilityIdentifier = "lbl_detail"
        self.recoverBtn.accessibilityIdentifier = "btn_recover"
        self.txtfldEmail?.accessibilityIdentifier = "tf_email"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }
    
    private func setupAccessibility(){
        self.cancelBtn.accessibilityTraits = .button
        self.cancelBtn.accessibilityLabel = "accessibility_btn_cancel".localized()
        self.cancelBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }
    
    @objc private func handleDynamicTypeChange() {
        // Dynamic font
        
        detailLabel.adjustsFontForContentSizeCategory = true
        detailLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 18, maxSize: nil)
        
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
        
        self.pwdCheckViewController?.pwdCheckTopLabel.adjustsFontForContentSizeCategory = true
        self.pwdCheckViewController?.pwdCheckTopLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: 20)
        self.pwdCheckViewController?.pwdCheckDetailLabel.adjustsFontForContentSizeCategory = true
        self.pwdCheckViewController?.pwdCheckDetailLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: 20)
        
        self.recoverBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        self.recoverBtn.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 18, maxSize: 25)
    }

    deinit {
        SCDataUIEvents.discardNotifications(for: self)       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshNavigationBarStyle()
    }

    override func viewDidAppear(_ animated: Bool) {
        self.pwdCheckVCHeightConstraint.constant =  (self.pwdCheckViewController?.view.intrinsicContentSize.height)!
        self.view.setNeedsLayout()
    }
    
    /**
     *
     * Handle Keyboard
     *
     */
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let height = keyboardFrame.height + keyboardOffsetSpace
        self.keyboardHeight = height
        
        self.contentScrollview.contentInset.bottom = height
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        self.contentScrollview.contentInset.bottom = 0.0
        self.contentScrollview.contentOffset = CGPoint(x: 0, y: 0)
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
    
    @IBAction func recoveryBtnWasPressed(_ sender: Any) {
        self.activeComponent?.resignResponder()
        self.presenter.recoveryWasPressed()
    }
    
    @IBAction func cancelBtnWasPressed(_ sender: Any) {
        self.activeComponent?.resignResponder()
        self.presenter.cancelWasPressed()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
 
    private func textField(for inputField: SCPWDRestoreUnlockInputFields) -> SCTextfieldComponent?{
        switch inputField {
        case .email:
            return self.txtfldEmail
        case .pwd1:
            return self.txtfldPwd1
        case .pwd2:
            return self.txtfldPwd2
        }
        
    }

    func restoreField(for inputField: SCTextfieldComponent? ) ->  SCPWDRestoreUnlockInputFields?{
        switch inputField {
        case self.txtfldEmail:
            return .email
        case self.txtfldPwd1:
            return.pwd1
        case self.txtfldPwd2:
            return .pwd2
        default:
            return nil
        }
        
    }

}

extension SCPWDRestoreUnlockVC: SCPWDRestoreUnlockDisplaying {
    func setupNavigationBar(title: String, backTitle: String){
        self.navigationItem.title = title
        self.navigationItem.backBarButtonItem?.title = ""
    }
    
    func setupUI(){        
        self.txtfldEmail?.disallowedCharacters = " "
        
        self.detailLabel.adaptFontSize()
        
        self.recoverBtn.customizeBlueStyle()
        self.recoverBtn.titleLabel?.adaptFontSize()
        
    }
    
    func refreshUI(screenTitle: String, detail : String, iconName : String, btnText: String, defaultEmail : String) {
        
        self.detailLabel?.text = detail
        self.navigationItem.title = screenTitle
        self.iconImageView.image = UIImage(named: iconName)
        self.txtfldEmail?.text = defaultEmail
        self.defaultEMail = defaultEmail
        self.txtfldEmail?.initialText = defaultEmail
        self.recoverBtn.setTitle(btnText.localized(), for: .normal)
    }
    
    func getValue(for inputField: SCPWDRestoreUnlockInputFields) -> String?{
        return self.textField(for: inputField)!.text
    }
    
    func getFieldType(for inputField: SCPWDRestoreUnlockInputFields) -> SCTextfieldComponentType{
        return self.textField(for: inputField)!.textfieldType
    }
    
    func getValidationState(for inputField: SCPWDRestoreUnlockInputFields) -> SCTextfieldValidationState{
        return self.textField(for: inputField)!.validationState
    }
    
    func hideError(for inputField: SCPWDRestoreUnlockInputFields){
        self.textField(for: inputField)?.hideError()
        self.textField(for: inputField)?.validationState = .unmarked
    }
    func setEnable(for inputField: SCPWDRestoreUnlockInputFields,enabled : Bool ){
        self.textField(for: inputField)?.setEnabled(enabled)
    }
    
    func showError(for inputField: SCPWDRestoreUnlockInputFields, text: String){
        self.textField(for: inputField)?.showError(message: text)
        self.updateValidationState(for: inputField, state: .wrong)
    }
    
    func showMessagse(for inputField: SCPWDRestoreUnlockInputFields, text: String, color: UIColor){
        self.textField(for: inputField)?.show(message: text, color: color)
    }
    
    func deleteContent(for inputField: SCPWDRestoreUnlockInputFields){
        self.textField(for: inputField)?.deleteContent()
    }
    
    func updateValidationState(for inputField: SCPWDRestoreUnlockInputFields, state: SCTextfieldValidationState){
        self.textField(for: inputField)?.validationState = state
        
        if (inputField == .pwd1 || inputField == .pwd2) && state == .ok{
             self.textField(for: inputField)?.setLineColor(UIColor(named: "CLR_LABEL_TEXT_GREEN")!)
        }
    }

    func dismissView(animated flag: Bool, completion: (() -> Void)? = nil){
        if let navigationController = self.presentingViewController as? UINavigationController {
            navigationController.popToRootViewController(animated: false)
        }
        self.dismiss(animated: flag, completion: completion)
    }

    func overlay(viewController: UIViewController, title: String) {
         self.navigationItem.title = title
         self.navigationItem.backBarButtonItem = nil
         self.navigationItem.hidesBackButton = true
         self.view.addSubview((viewController.view)!)
         viewController.view.frame = self.contentScrollview.frame
     }

    func setRecoverButtonState(_ state : SCCustomButtonState){
        self.recoverBtn.btnState = state
    }

    func recoverButtonState() -> SCCustomButtonState {
        return self.recoverBtn.btnState
    }

    func updatePWDChecker(charCount: Int,  minCharReached: Bool, symbolAvailable: Bool, digitAvailable: Bool){
        self.pwdCheckViewController?.refreshWith(charCount: charCount, minCharReached: minCharReached, symbolAvailable: symbolAvailable, digitAvailable: digitAvailable)
    }

}

