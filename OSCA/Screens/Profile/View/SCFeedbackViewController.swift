//
//  FeedbackViewController.swift
//  OSCA
//
//  Created by Ayush on 09/09/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCFeedbackViewController: UIViewController {

    @IBOutlet weak var contentScrollView: UIScrollView!
    public var presenter: SCFeedbackPresenting!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var firstQuestionLabel: UILabel!

    @IBOutlet weak var sendButton: SCCustomButton!
    @IBOutlet weak var secondAnswerTextView: UITextView!
    @IBOutlet weak var secondQuestionLabel: UILabel!
    @IBOutlet weak var firstAnswerTextView: UITextView!
    
    @IBOutlet weak var firstAnsCharCountLabel: UILabel!
    @IBOutlet weak var secondAnsCharCountLabel: UILabel!

    @IBOutlet weak var contactViaEmailSwitchButton: UISwitch!
    @IBOutlet weak var canWeContactYouTitleLabel: UILabel!
    @IBOutlet weak var contactMeViaLabel: UILabel!

    var emailTextField : SCTextfieldComponent?
    var activeComponent: UITextView?

    static private let MaxCharacterCount = 5000
    private let keyboardOffsetSpace : CGFloat = 60.0
    var keyboardHeight : CGFloat = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstAnswerTextView.delegate = self
        secondAnswerTextView.delegate = self
        self.hideKeyboardWhenTappedAround()
        self.setupUI()
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        self.adaptFontSize()
        self.sendButton.customizeBlueStyle()
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification , object: nil)
   }
    
    private func setupUI() {
        
        self.navigationItem.title = "p_001_feedback_title".localized()
        self.navigationItem.hidesBackButton = true
        self.navigationItem.setRightBarButton(UIBarButtonItem(image: UIImage(named: "icon_close"), style: .plain, target: self, action: #selector(closeButtonTapped)), animated: false)
        firstAnswerTextView.layer.borderWidth = 1
        firstAnswerTextView.layer.borderColor = UIColor.gray.cgColor
        secondAnswerTextView.layer.borderWidth = 1
        secondAnswerTextView.layer.borderColor = UIColor.gray.cgColor
        
        self.titleLabel.text = "feedback_header".localized()
        self.descriptionLabel.attributedText = "feedback_description".localized().applyHyphenation()
        self.firstQuestionLabel.text = "feedback_box_title".localized()
        self.secondQuestionLabel.text = "feedback_box_title1".localized()
        self.sendButton.setTitle("feedback_send_btn".localized(), for: .normal)
        
        self.firstAnsCharCountLabel.text = "0/\(SCFeedbackViewController.MaxCharacterCount)"
        self.firstAnsCharCountLabel?.textColor = UIColor(named: "CLR_LABEL_TEXT_GRAY_GRAY")
        
        self.secondAnsCharCountLabel.text = "0/\(SCFeedbackViewController.MaxCharacterCount)"
        self.secondAnsCharCountLabel?.textColor = UIColor(named: "CLR_LABEL_TEXT_GRAY_GRAY")
        
        contactViaEmailSwitchButton.isOn = false
        canWeContactYouTitleLabel.text = LocalizationKeys.SCFeedbackViewController.canWeContactYouTitleLabel.localized()
        contactMeViaLabel.text = LocalizationKeys.SCFeedbackViewController.contactMeViaLabel.localized()
        emailTextField?.setEnabled(false)
        contactViaEmailSwitchButton.tintColor = UIColor(named: "CLR_BUTTON_BLUE_BCKGRND")
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        emailTextField?.view.addGestureRecognizer(tap)
        firstQuestionLabel.numberOfLines = 0
        secondQuestionLabel.numberOfLines = 0
        canWeContactYouTitleLabel.numberOfLines = 0
        contactMeViaLabel.numberOfLines = 0
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs() {
        self.sendButton.accessibilityIdentifier = "btn_send"
        self.titleLabel.accessibilityIdentifier = "lbl_title"
        self.descriptionLabel.accessibilityIdentifier = "lbl_desc"
        self.firstQuestionLabel.accessibilityIdentifier = "lbl_firstQuestion"
        self.secondQuestionLabel.accessibilityIdentifier = "lbl_secondQuestion"
        self.firstAnswerTextView.accessibilityIdentifier = "txtVeew_firstAnswer"
        self.secondAnswerTextView.accessibilityIdentifier = "lbl_secondAnswer"
    }
    
    private func setupAccessibility() {
        self.sendButton.accessibilityTraits = .button
        self.sendButton.accessibilityLabel = "send_button"
        self.sendButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        titleLabel.accessibilityTraits = .header
    }
    
    @objc private func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if let enabled = emailTextField?.isEnabled(), enabled == true {
            emailTextField?.becomeResponder()
        }
    }

    private func adaptFontSize() {
        titleLabel.adaptFontSize()
        descriptionLabel.adaptFontSize()
        firstQuestionLabel.adaptFontSize()
        secondQuestionLabel.adaptFontSize()
        firstAnsCharCountLabel.adaptFontSize()
        secondAnsCharCountLabel.adaptFontSize()
        
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 18, maxSize: nil)
        
        descriptionLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16, maxSize: nil)
        
        firstQuestionLabel.adjustsFontForContentSizeCategory = true
        firstQuestionLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 14, maxSize: nil)
        
        secondQuestionLabel.adjustsFontForContentSizeCategory = true
        secondQuestionLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 14, maxSize: nil)
        
        canWeContactYouTitleLabel.adjustsFontForContentSizeCategory = true
        canWeContactYouTitleLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 14, maxSize: nil)
        
        contactMeViaLabel.adjustsFontForContentSizeCategory = true
        contactMeViaLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 14, maxSize: 28)
        
        emailTextField?.textField.adjustsFontForContentSizeCategory = true
        emailTextField?.textField.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 20, maxSize: 25)
        emailTextField?.placeholderLabel.adjustsFontForContentSizeCategory = true
        emailTextField?.placeholderLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 15, maxSize: 25)
        emailTextField?.errorLabel.adjustsFontForContentSizeCategory = true
        emailTextField?.errorLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        
        sendButton.titleLabel?.adjustsFontForContentSizeCategory = true
        sendButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 18, maxSize: 36)
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        self.presenter.sendButtonPressed()
    }
    
    @IBAction func contactMeViaEmailTapped(_ sender: Any) {
        emailTextField?.setEnabled(contactViaEmailSwitchButton.isOn)
        emailTextField?.seperatorView.backgroundColor = contactViaEmailSwitchButton.isOn ? UIColor(named: "CLR_BUTTON_BLUE_BCKGRND") : UIColor.lightGray
        emailTextField?.placeholderLabel.textColor =  contactViaEmailSwitchButton.isOn ? UIColor(named: "CLR_LABEL_TEXT_BLACK")! : .lightGray
        presenter.contactMeViaEmailTapped(isContactViaEmailEnabled: contactViaEmailSwitchButton.isOn, email: emailTextField?.text)
        setSendButtonState(validateAllFields())
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
        
        self.contentScrollView?.contentInset.bottom = height
        
        if self.activeComponent != nil {
            self.scrollComponentToVisibleArea(component: self.activeComponent!)
        }
    }
    
    private func adjustContentForHidingKeyboard() {
        self.contentScrollView?.contentInset.bottom = 0.0
    }
    
    /**
     *
     * Method to scroll to a component
     */
    
    func scrollComponentToVisibleArea(component: UITextView) {
        var navBarHeight : CGFloat = 0.0
        var aRect : CGRect = self.contentScrollView.bounds
        
        if let navigationController = self.navigationController {
            navBarHeight = navigationController.navigationBar.frame.size.height + navigationController.navigationBar.frame.origin.y
        }
        
        aRect.size.height -= self.keyboardHeight
        aRect.size.height += navBarHeight
        let fieldPoint = CGPoint(x: 0.0 , y: component.frame.origin.y + component.frame.size.height)
        if !(aRect.contains(fieldPoint))
        {
            self.contentScrollView.setContentOffset(CGPoint(x:0, y:component.frame.origin.y - aRect.size.height + keyboardOffsetSpace + component.frame.size.height  ), animated: true)
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.destination {
            
        case let textfield as SCTextfieldComponent:
            textfield.delegate = self
            self.emailTextField = self.presenter.configureField(textfield, identifier: segue.identifier, type: .email, autocapitalizationType: .none) as? SCTextfieldComponent ?? self.emailTextField
        default:
            break
        }
    }
    
    func validateAllFields() -> SCCustomButtonState   {
        if firstAnswerTextView.text.isEmpty && secondAnswerTextView.text.isEmpty {
            return .disabled
        } else {
            if contactViaEmailSwitchButton.isOn && SCInputValidation.validateEmail(emailTextField?.text ?? "").isValid {
                return .normal
            } else if contactViaEmailSwitchButton.isOn == false {
                return .normal
            } else {
                return .disabled
            }
        }
    }

}

extension SCFeedbackViewController: SCFeedbackDisplaying {
    func updateSendButtonState() {
        setSendButtonState(validateAllFields())
    }

    func getAnswerForWhatDidYouLike() -> String? {
        return self.firstAnswerTextView.text
    }
    
    func getAnswerForWhatCanWeDoBetter() -> String? {
        return self.secondAnswerTextView.text
    }
    
    func getContactInformation() -> String? {
        return contactViaEmailSwitchButton.isOn ? emailTextField?.text : nil
    }
    
    func push(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func setupUI(email : String){
        
    }
    
    func dismissView(completion: (() -> Void)? = nil) {
        self.dismiss(animated: true, completion: completion)
    }
    
    func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func dismiss(completion: (() -> Void)?) {
        self.dismiss(animated: true, completion: completion)
    }
    
    func setSendButtonState(_ state : SCCustomButtonState) {
        self.sendButton.btnState = state
    }
    
    func showAlert(error: SCWorkerError) {
        self.showErrorDialog(error)
    }
    
    func updateEmail(id: String) {
        emailTextField?.placeholderLabel.isHidden = false
        emailTextField?.text = id
    }
    
    func hideError(for inputField: SCRegistrationInputFields) {
        self.textField(for: inputField)?.hideError()
        self.textField(for: inputField)?.validationState = .unmarked
    }
    
    func updateValidationState(for inputField: SCRegistrationInputFields, state: SCTextfieldValidationState) {
        self.textField(for: inputField)?.validationState = state
        
        if (inputField == .pwd1 || inputField == .pwd2) && state == .ok{
            self.textField(for: inputField)?.setLineColor(UIColor(named: "CLR_LABEL_TEXT_GREEN")!)
        }
    }
    
    func showError(for inputField: SCRegistrationInputFields, text: String) {
        self.textField(for: inputField)?.showError(message: text)
        self.updateValidationState(for: inputField, state: .wrong)
    }
    
    private func textField(for inputField: SCRegistrationInputFields) -> SCTextfieldComponent?{
        switch inputField {
        case .email:
            return emailTextField
        default:
            return nil
        }
        
    }
}

extension SCFeedbackViewController: SCTextfieldComponentDelegate {
    func textFieldComponentShouldReturn(component: SCTextfieldComponent) -> Bool {
        return true
    }
    
    func textFieldComponentEditingBegin(component: SCTextfieldComponent) {
        
    }
    
    func textFieldComponentDidChange(component: SCTextfieldComponent) {
        presenter.textFieldComponentDidChange(for: .email)
    }
    
    func textFieldComponentEditingEnd(component: SCTextfieldComponent) {
        presenter.txtFieldEditingDidEnd(value: component.text ?? "", inputField: .email, textFieldType: component.textfieldType)
    }
    
    
}

extension SCFeedbackViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.activeComponent = textView
        self.scrollComponentToVisibleArea(component:textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty || (textView.text != " " && textView.text != "\n") {
            if firstAnswerTextView.text.isEmpty && secondAnswerTextView.text.isEmpty {
                sendButton.btnState = .disabled
            } else {
                if contactViaEmailSwitchButton.isOn && SCInputValidation.validateEmail(emailTextField?.text ?? "").isValid {
                    sendButton.btnState = .normal
                } else if contactViaEmailSwitchButton.isOn == false {
                    sendButton.btnState = .normal
                } else {
                    sendButton.btnState = .disabled
                }
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let oldChar = textView.text.count - range.length
        let oldRemainingChar = SCFeedbackViewController.MaxCharacterCount - oldChar
        let newChar = oldChar + text.count
        let newRemainingChar = SCFeedbackViewController.MaxCharacterCount - newChar
        let replaceChar = newRemainingChar > 0 ? text.count : oldRemainingChar

        if let textRange = textView.textRange(for: range),
            replaceChar > 0 || range.length > 0
        {
            textView.replace(textRange, withText: String(text.prefix(replaceChar)))
            if textView == firstAnswerTextView{
                self.firstAnsCharCountLabel.text = "\(textView.text.count)/\(SCFeedbackViewController.MaxCharacterCount)"
            }else{
                self.secondAnsCharCountLabel.text = "\(textView.text.count)/\(SCFeedbackViewController.MaxCharacterCount)"
            }
        }

        return false
    }
}

extension SCFeedbackViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        setSendButtonState(validateAllFields())
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        setSendButtonState(validateAllFields())
        return true
    }
}
