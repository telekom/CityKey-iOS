//
//  SCTextViewComponent.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 06/12/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

@objc protocol SCTextViewComponentDelegate : NSObjectProtocol
{
    func textViewComponentEditingBegin(component: SCTextViewComponent)
    func textViewComponentDidChange(component: SCTextViewComponent)
    func textViewComponentEditingEnd(component: SCTextViewComponent)
}

class SCTextViewComponent: UIViewController, UITextViewDelegate, SCTextFieldConfigurable {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var validationStateImageView: UIImageView!
    @IBOutlet weak var characterCountLabel: UILabel!

    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var validationStateImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var disclaimerLabel: UILabel!

    weak var delegate:SCTextViewComponentDelegate?

    private var enabled: Bool = true
    private var validationStateWidth : CGFloat!
    var isEditable: Bool = false

    var disallowedCharacters: String = ""
    var placeholderText: String = ""
    var textViewType : SCTextfieldComponentType = .text
    var maxCharCount : Int = 500//255
    var autoCapitalization: UITextAutocapitalizationType = .none
    var disclaimerText: String?
    
    var accessibilityIdentifier: String?{
        didSet {
            if accessibilityIdentifier != nil{
                self.textView?.accessibilityIdentifier = "txtView_" + accessibilityIdentifier!
                self.errorLabel?.accessibilityIdentifier = "lbl_error_" + accessibilityIdentifier!
                self.placeholderLabel?.accessibilityIdentifier = "lbl_placeholder_" + accessibilityIdentifier!
                self.validationStateImageView?.accessibilityIdentifier = "img_" + accessibilityIdentifier!
            } else {
                self.textView?.accessibilityIdentifier = nil
                self.errorLabel?.accessibilityIdentifier = nil
                self.placeholderLabel?.accessibilityIdentifier = nil
                self.validationStateImageView?.accessibilityIdentifier = nil
            }
        }
    }

    var validationState: SCTextfieldValidationState = .unmarked {
        didSet {
            switch validationState {
            case .warning:
                self.validationStateImageView?.image = UIImage(named: "icon_val_warning")
                self.validationStateImageViewWidthConstraint.constant = self.validationStateWidth
                self.errorLabel.textColor = UIColor(named: "CLR_LABEL_TEXT_ORANGE")!
                self.seperatorView.backgroundColor = UIColor(named: "CLR_LABEL_TEXT_RED")!
            case .wrong:
                self.validationStateImageView?.image = UIImage(named: "icon_val_error")
                self.validationStateImageViewWidthConstraint.constant = self.validationStateWidth
                self.errorLabel.textColor = UIColor(named: "CLR_LABEL_TEXT_RED")!
                self.seperatorView.backgroundColor = UIColor(named: "CLR_LABEL_TEXT_RED")!
            case .ok:
                self.validationStateImageView?.image = UIImage(named: "icon_val_ok")
                self.validationStateImageViewWidthConstraint.constant = self.validationStateWidth
                self.seperatorView.backgroundColor = UIColor(named: "CLR_INPUT")!
            default:
                self.validationStateImageView?.image = nil
                self.validationStateImageViewWidthConstraint.constant = 0.0
                self.seperatorView.backgroundColor = enabled ? UIColor(named: "CLR_INPUT")! : UIColor(named: "CLR_LABEL_TEXT_GRAY_GRAY")!
            }
        }
    }

    
    var initialText: String? {
        didSet {
            self.textView?.text = initialText
            self.refreshTopPlaceholderLabel()
        }
    }
    
    var text: String? {
        get {
            return self.textView?.text
        }
        set(newVal) { //you can use any name for the passed parameter.Default is newValue
            self.textView?.text = newVal
        }
    }
    
    func configure(placeholder: String, fieldType: SCTextfieldComponentType, maxCharCount: Int, autocapitalization: UITextAutocapitalizationType, disclaimerText: String?) {
        self.placeholderText = placeholder
        self.textViewType = fieldType
        self.maxCharCount = maxCharCount
        self.autoCapitalization = autocapitalization
        self.disclaimerText = disclaimerText
        
        self.updatePlaceholder(text: self.placeholderText)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.validationStateWidth = self.validationStateImageViewWidthConstraint.constant
        
        self.errorLabel.adaptFontSize()
        self.placeholderLabel.adaptFontSize()
        self.characterCountLabel.adaptFontSize()
        disclaimerLabel.adaptFontSize()
        
        self.hideError()
        self.textView.delegate = self
        self.textView?.text = self.placeholderText
        self.placeholderLabel?.text = self.placeholderText
        self.placeholderLabel?.textColor = .lightGray
        self.textView.textColor = .lightGray
        
        self.characterCountLabel.text = "0/\(self.maxCharCount)"
        self.characterCountLabel?.textColor = .lightGray

        self.textView.autocapitalizationType = self.autoCapitalization

        self.updatePlaceholder(text: self.placeholderText)
        self.setTextViewType(self.textViewType)
        self.setMaxAllowedTextfieldCharacters(maxCharCount)
        
        disclaimerLabel.textColor = .lightGray
        disclaimerLabel.text = disclaimerText
        
//        self.textView?.text = self.initialText
        self.validationState = .unmarked
        self.setEnabled(self.enabled)
 
        self.refreshTopPlaceholderLabel()
    }
    
    func updatePlaceholder(text: String){
        self.placeholderLabel?.text = text
        self.placeholderText = text
    }
    
   func showError(message: String){
        self.characterCountLabel.isHidden = true
        self.errorLabel.isHidden = false
        self.disclaimerLabel.isHidden = true
        self.errorLabel.text = message
        self.errorLabel.textColor = UIColor(named: "CLR_LABEL_TEXT_RED")!
        self.seperatorView.backgroundColor = UIColor(named: "CLR_LABEL_TEXT_RED")!
    
        let errorMsg = message != "r_001_registration_error_password_too_weak".localized() ? message : "accessibility_password_too_weak".localized()
        self.errorLabel.accessibilityLabel = errorMsg
        self.errorLabel.accessibilityTraits = .staticText
        self.errorLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        UIAccessibility.post(notification: .announcement, argument: errorMsg)
    }
    
    func show(message: String, color : UIColor){
        self.characterCountLabel.isHidden = true
        self.errorLabel.isHidden = false
        self.disclaimerLabel.isHidden = true
        self.errorLabel.text = message
        self.errorLabel.textColor = color
        self.seperatorView.backgroundColor = color
        
        let errorMsg = message != "r_001_registration_hint_password_strong".localized() ? message : "accessibility_password_strong".localized()
        self.errorLabel.accessibilityLabel = errorMsg
        self.errorLabel.accessibilityTraits = .staticText
        self.errorLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        UIAccessibility.post(notification: .announcement, argument: errorMsg)
    }
    
    func hideError(){
        self.characterCountLabel.isHidden = false
        self.errorLabel.isHidden = true
        self.disclaimerLabel.isHidden = false
        self.seperatorView.backgroundColor = enabled ? UIColor(named: "CLR_INPUT")! : UIColor(named: "CLR_LABEL_TEXT_GRAY_GRAY")!
    }
    
    func setLineColor(_ color : UIColor){
        self.seperatorView.backgroundColor = color
    }

    func resignResponder(){
        self.textView.resignFirstResponder()
    }

    func becomeResponder(){
        self.textView.becomeFirstResponder()
    }

    func textfieldFrame() -> CGRect{
        return self.view.superview?.frame ?? self.view.frame
    }

    func setTextViewType(_ type : SCTextfieldComponentType){
        self.textViewType = type
        self.textView?.keyboardType = .asciiCapable
    }
    
    func setMaxAllowedTextfieldCharacters(_ charCount : Int){
        self.maxCharCount = charCount
    }

    func maxAllowedTextfieldCharacters() -> Int{
        return self.maxCharCount
    }

    func isEnabled()-> Bool{
        return self.enabled
    }
    
    func setUppercaseStart() {
        self.textView?.autocapitalizationType = .words
    }

    func setEnabled(_ enabled : Bool) {
        self.enabled = enabled
        self.textView?.textColor = self.isEditable ? UIColor(named: "CLR_LABEL_TEXT_BLACK")! : UIColor(named: "CLR_LABEL_TEXT_GRAY_GRAY")!
        self.seperatorView?.backgroundColor = enabled ? UIColor(named: "CLR_INPUT")! : UIColor(named: "CLR_LABEL_TEXT_GRAY_GRAY")!
    }

    func deleteContent() {
        self.text = nil
        self.refreshTopPlaceholderLabel()
        self.hideError()
    }
    
    private func refreshTopPlaceholderLabel(){
        self.placeholderLabel?.text = self.placeholderText
        self.placeholderLabel?.isHidden = self.textView.text.contains(self.placeholderText) ? true : false
        self.textViewTopConstraint.constant = !self.textView.text.contains(self.placeholderText) ? 22 : 0
        self.textView?.textColor = self.isEditable ? UIColor(named: "CLR_LABEL_TEXT_BLACK")! : UIColor(named: "CLR_LABEL_TEXT_GRAY_GRAY")!

    }
    
    //  UITextViewDelegate methods

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.rangeOfCharacter(from: CharacterSet(charactersIn: self.disallowedCharacters)) != nil{
            return false
        }
        
        // here we check only the max length

        let oldChar = textView.text.count - range.length
        let oldRemainingChar = maxCharCount - oldChar
        let newChar = oldChar + text.count
        let newRemainingChar = maxCharCount - newChar
        let replaceChar = newRemainingChar > 0 ? text.count : oldRemainingChar

        if let textRange = textView.textRange(for: range),
            replaceChar > 0 || range.length > 0
        {
            textView.replace(textRange, withText: String(text.prefix(replaceChar)))
            characterCountLabel.text = "\(textView.text.count)/\(maxCharCount)"
        }

        return false
    }

    func textViewDidChange(_ textView: UITextView) {
        self.refreshTopPlaceholderLabel()
        self.textViewHeightConstraint.constant = !self.isEnabled() ? 0 : self.textView.calculateViewHeightWithCurrentWidth()
        self.delegate?.textViewComponentDidChange(component: self)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.isEditable = true
        self.textView.text = !self.textView.text.contains(self.placeholderText) ? textView.text : ""
        self.refreshTopPlaceholderLabel()
        self.delegate?.textViewComponentEditingBegin(component: self)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.delegate?.textViewComponentEditingEnd(component: self)
        self.refreshTopPlaceholderLabel()
    }

    func configure(placeholder: String, fieldType: SCTextfieldComponentType, maxCharCount: Int, autocapitalization: UITextAutocapitalizationType) {
        //do nothing
    }
}
