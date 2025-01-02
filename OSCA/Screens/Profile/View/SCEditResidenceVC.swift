//
//  SCEditResidenceVC.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 15/02/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCEditResidenceVC: UIViewController, SCTextfieldComponentDelegate {
    
    public var presenter: SCEditResidencePresenting!
    
    private let keyboardOffsetSpace : CGFloat = 35.0
    var keyboardHeight : CGFloat = 0.0
    
    @IBOutlet weak var contentScrollview: UIScrollView!
    @IBOutlet weak var submitBtn: SCCustomButton!
    @IBOutlet weak var closeBtn: UIBarButtonItem!

    private var txtfldPostcode : SCTextfieldComponent?
    private var txtfldCurrentPostcode : SCTextfieldComponent?

    private  var activeComponent: SCTextfieldComponent?
    
    private var oldPostcode: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        self.shouldNavBarTransparent = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification , object: nil)
        
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
        handleDynamicType()
        SCDataUIEvents.registerNotifications(for: self, on: UIContentSizeCategory.didChangeNotification, with: #selector(handleDynamicType))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshNavigationBarStyle()
    }
    
    @objc private func handleDynamicType() {
        // Setup Dynamic font for txtFldPostcode
        txtfldPostcode?.textField.adjustsFontForContentSizeCategory = true
        txtfldPostcode?.textField.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 20, maxSize: 25)
        txtfldPostcode?.placeholderLabel.adjustsFontForContentSizeCategory = true
        txtfldPostcode?.placeholderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 15, maxSize: 25)
        txtfldPostcode?.errorLabel.adjustsFontForContentSizeCategory = true
        txtfldPostcode?.errorLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        
        // Setup Dynamic font for txtfldCurrentPostcode
        txtfldCurrentPostcode?.textField.adjustsFontForContentSizeCategory = true
        txtfldCurrentPostcode?.textField.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 20, maxSize: 25)
        txtfldCurrentPostcode?.placeholderLabel.adjustsFontForContentSizeCategory = true
        txtfldCurrentPostcode?.placeholderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 15, maxSize: 25)
        txtfldCurrentPostcode?.errorLabel.adjustsFontForContentSizeCategory = true
        txtfldCurrentPostcode?.errorLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        
        // Setup Dynamic font for submitBtn
        submitBtn.titleLabel?.adjustsFontForContentSizeCategory = true
        submitBtn.titleLabel?.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 18, maxSize: 30)
    }

    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.closeBtn.accessibilityIdentifier = "btn_close"
        self.txtfldPostcode?.accessibilityIdentifier = "tf_postcode"
        self.txtfldCurrentPostcode?.accessibilityIdentifier = "tf_current_postcode"
        self.submitBtn.accessibilityIdentifier = "btn_submit"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }
    
    private func setupAccessibility(){
        self.closeBtn.accessibilityTraits = .button
        self.closeBtn.accessibilityLabel = "accessibility_btn_close".localized()
        self.closeBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
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
        self.presenter.postcodeFieldDidEnd()
    }
    
    func textFieldComponentDidChange(component: SCTextfieldComponent) {
        self.presenter.postcodeFieldDidChange()
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
            case "sgtxtfldCurrentPostcode":
                self.txtfldCurrentPostcode = textfield
                self.txtfldCurrentPostcode?.configure(placeholder: "p_003_profile_current_postcode_label".localized(), fieldType: .postalCode, maxCharCount: 5, autocapitalization: .none)
                self.txtfldCurrentPostcode?.setEnabled(false)
                self.txtfldCurrentPostcode?.initialText = self.oldPostcode

            case "sgtxtfldPostcode":
                self.txtfldPostcode = textfield
                self.txtfldPostcode?.configure(placeholder: "p_003_profile_new_postcode_input_hint".localized(), fieldType: .postalCode, maxCharCount: 5, autocapitalization: .none)
                
            default:
                break
            }
        default:
            break
        }
    }
    
    @IBAction func submitBtnWasPressed(_ sender: Any) {
        self.activeComponent?.resignResponder()
        
        self.presenter.confirmWasPressed()
    }
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        self.presenter.closeButtonWasPressed()
    }
    
}

extension SCEditResidenceVC: SCEditResidenceDisplaying {
    
    func setupNavigationBar(title: String){
        self.navigationItem.title = "p_003_profile_new_postcode_title".localized()
        self.navigationItem.backBarButtonItem?.title = ""
    }
    
    func setupUI(postcode : String){

        self.submitBtn.customizeBlueStyle()
        self.submitBtn.titleLabel?.adaptFontSize()
        self.submitBtn.setTitle("p_003_profile_email_change_btn_save".localized(), for: .normal)
        
        self.txtfldPostcode?.disallowedCharacters = " "

        self.oldPostcode = postcode
        self.txtfldCurrentPostcode?.initialText  = postcode
        
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
    
    func postcodeFieldContent() -> String? {
        return self.txtfldPostcode?.text
    }

    func showPostcodeError(message: String){
        self.txtfldPostcode?.showError(message: message)
        self.txtfldPostcode?.validationState = .wrong
    }
    
    func showPostcodeMessage(message: String){
        self.txtfldPostcode?.show(message: message, color: UIColor(named: "CLR_LABEL_TEXT_GREEN")!)
        self.txtfldPostcode?.validationState = .ok
    }
    
    func showPostcodeOK() {
        self.txtfldPostcode?.validationState = .ok
    }
    
    func hidePostcodeError(){
        self.txtfldPostcode?.hideError()
        self.txtfldPostcode?.validationState = .unmarked
    }
    
    func dismiss(completion: (() -> Void)?) {
        self.dismiss(animated: true, completion: completion)
    }
    
    func dismissView(completion: (() -> Void)?) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
