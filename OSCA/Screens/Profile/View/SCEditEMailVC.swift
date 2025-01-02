//
//  SCEditEMailVC.swift
//  SmartCity
//
//  Created by Michael on 29.03.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCEditEMailVC: UIViewController, SCTextfieldComponentDelegate {
    
    public var presenter: SCEditEMailPresenting!
    
    private let keyboardOffsetSpace : CGFloat = 35.0
    var keyboardHeight : CGFloat = 0.0
    
    @IBOutlet weak var contentScrollview: UIScrollView!
    @IBOutlet weak var submitBtn: SCCustomButton!
    @IBOutlet weak var pwdForgottenBtn: UIButton!
    @IBOutlet weak var closeBtn: UIBarButtonItem!

    private var txtfldEmail : SCTextfieldComponent?
    private var txtfldCurrentEmail : SCTextfieldComponent?

    private  var activeComponent: SCTextfieldComponent?
    private  var finishViewController : SCEditEMailFinishedVC?
    
    private var oldEmail: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        self.shouldNavBarTransparent = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification , object: nil)
        
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
        self.handleDynamicTypeChange()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDynamicTypeChange), name: UIContentSizeCategory.didChangeNotification, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshNavigationBarStyle()
    }

    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.closeBtn.accessibilityIdentifier = "btn_close"
        self.txtfldEmail?.accessibilityIdentifier = "tf_email"
        self.pwdForgottenBtn.accessibilityIdentifier = "btn_pwd_forgotten"
        self.txtfldCurrentEmail?.accessibilityIdentifier = "tf_current_email"
        self.submitBtn.accessibilityIdentifier = "btn_submit"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }
    
    private func setupAccessibility(){
        self.closeBtn.accessibilityTraits = .button
        self.closeBtn.accessibilityLabel = "accessibility_btn_close".localized()
        self.closeBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }
    
    @objc private func handleDynamicTypeChange() {
        // Dynamic font
        // Setup Dynamic font for Current email
        self.txtfldCurrentEmail?.textField.adjustsFontForContentSizeCategory = true
        self.txtfldCurrentEmail?.textField.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 20, maxSize: 25)
        self.txtfldCurrentEmail?.placeholderLabel.adjustsFontForContentSizeCategory = true
        self.txtfldCurrentEmail?.placeholderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 15, maxSize: 25)
        self.txtfldCurrentEmail?.errorLabel.adjustsFontForContentSizeCategory = true
        self.txtfldCurrentEmail?.errorLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        
        // Setup Dynamic font for New email
        self.txtfldEmail?.textField.adjustsFontForContentSizeCategory = true
        self.txtfldEmail?.textField.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 20, maxSize: 25)
        self.txtfldEmail?.placeholderLabel.adjustsFontForContentSizeCategory = true
        self.txtfldEmail?.placeholderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 15, maxSize: 25)
        self.txtfldEmail?.errorLabel.adjustsFontForContentSizeCategory = true
        self.txtfldEmail?.errorLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        
        self.submitBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        self.submitBtn.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 18, maxSize: 30)
            
    }
    
    deinit {
        SCDataUIEvents.discardNotifications(for: self)
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
        
        if self.activeComponent != nil {
            self.scrollComponentToVisibleArea(component: self.activeComponent!)
        }
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        self.contentScrollview.contentInset.bottom = 0.0
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
    
    func textFieldComponentShouldReturn(component: SCTextfieldComponent) -> Bool {
        component.resignResponder()
        
        return true
    }
    
    func textFieldComponentEditingBegin(component: SCTextfieldComponent) {
        self.activeComponent = component
        self.scrollComponentToVisibleArea(component:component)
    }
    
    
    func textFieldComponentEditingEnd(component: SCTextfieldComponent) {
        self.presenter.emailFieldDidEnd()
    }
    
    func textFieldComponentDidChange(component: SCTextfieldComponent) {
        self.presenter.emailFieldDidChange()
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
            switch segue.identifier {
            case "sgtxtfldCurrentEmail":
                self.txtfldCurrentEmail = textfield
                self.txtfldCurrentEmail?.configure(placeholder: "p_003_profile_email_change_hint_cur_email".localized(), fieldType: .email, maxCharCount: 255, autocapitalization: .none)
                self.txtfldCurrentEmail?.setEnabled(false)
                self.txtfldCurrentEmail?.initialText = self.oldEmail
                
            case "sgtxtfldEmail":
                self.txtfldEmail = textfield
                self.txtfldEmail?.configure(placeholder: "p_003_profile_email_change_hint_new_email".localized(), fieldType: .email, maxCharCount: 255, autocapitalization: .none)
                
            default:
                break
            }
        default:
            break
        }
    }
    
    @IBAction func pwdForgottenBtnWasPressed(_ sender: Any) {
        self.activeComponent?.resignResponder()
        self.presenter.forgotPWDWasPressed()

    }
    
    @IBAction func submitBtnWasPressed(_ sender: Any) {
        self.activeComponent?.resignResponder()
        
        self.presenter.confirmWasPressed()
    }
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        self.presenter.closeButtonWasPressed()
    }
    
}

extension SCEditEMailVC: SCEditEMailDisplaying {
    
    func setupNavigationBar(title: String){
        self.navigationItem.title = "p_003_profile_email_change_title".localized()
        self.navigationItem.backBarButtonItem?.title = ""
        
    }
    
    func setupUI(email : String){
        self.pwdForgottenBtn.setTitle("p_005_profile_password_change_btn_forgot_password".localized(), for: .normal)
        self.pwdForgottenBtn.titleLabel?.adaptFontSize()

        self.submitBtn.customizeBlueStyle()
        self.submitBtn.titleLabel?.adaptFontSize()
        self.submitBtn.setTitle("p_003_profile_email_change_btn_save".localized(), for: .normal)
        
        self.txtfldEmail?.disallowedCharacters = " "

        self.oldEmail = email
        self.txtfldCurrentEmail?.initialText  = email
        
    }
    
    func setSubmitButtonState(_ state : SCCustomButtonState){
        self.submitBtn.btnState = state
    }
    
    func push(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func present(viewController: UIViewController) {
        self.definesPresentationContext = true
        self.present(viewController, animated: true, completion: nil)
    }
    
    func presentOnTop(viewController: UIViewController, completion: (() -> Void)? = nil) {
        SCUtilities.topViewController().present(viewController, animated: true, completion: completion)
    }
    
    func eMailFieldContent() -> String? {
        return self.txtfldEmail?.text
    }

    func showEMailError(message: String){
        self.txtfldEmail?.showError(message: message)
        self.txtfldEmail?.validationState = .wrong
    }
    
    func showEMailOK() {
        self.txtfldEmail?.validationState = .ok
    }
    
    func hideEMailError(){
        self.txtfldEmail?.hideError()
        self.txtfldEmail?.validationState = .unmarked
    }
    
    func dismiss(completion: (() -> Void)?) {
        self.dismiss(animated: true, completion: completion)
    }
    
}

