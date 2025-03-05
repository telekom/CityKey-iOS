/*
Created by Alexander Lichius on 09.08.19.
Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Alexander Lichius
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

class SCDeleteAccountConfirmationViewController: UIViewController {
    var presenter: SCDeleteAccountConfirmationPresenting!
    @IBOutlet weak var passwordTextfield: SCTextfieldWithoutCopy!
    @IBOutlet weak var passwordTextFieldTitleLabel: UILabel!
    @IBOutlet weak var showPasswordButton: UIButton!
    //@IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var deleteAccountConfirmationButton: SCCustomButton!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var recoverPasswordLabel: SCTopAlignLabel!
    @IBOutlet weak var baselineView: UIView!
    @IBOutlet weak var validationIconWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeBtn: UIBarButtonItem!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAccessibilityIDs()
        self.presenter.setDisplay(self)
        self.deleteAccountConfirmationButton.btnState = .normal
        self.passwordTextFieldTitleLabel.isHidden = true
        self.validationIconWidthConstraint.constant = 0
        self.presenter.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.passwordTextfield.accessibilityIdentifier = "txtfld_password"
        self.passwordTextFieldTitleLabel.accessibilityIdentifier = "lbl_password_title"
        self.showPasswordButton.accessibilityIdentifier = "btn_show_password"
        self.deleteAccountConfirmationButton.accessibilityIdentifier = "btn_conformation"
        self.passwordErrorLabel.accessibilityIdentifier = "lbl_error_password"
        self.recoverPasswordLabel.accessibilityIdentifier = "lbl_recover_pwd"
        self.titleLabel.accessibilityIdentifier = "lbl_title"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                if let image = self.showPasswordButton?.image(for: .normal){
                    self.showPasswordButton?.setImage(image.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!), for: .normal)
                }
            }
        }
    }

    
    @IBAction func ConfirmButtonWasPressed(_ sender: Any) {
        self.passwordTextfield.resignFirstResponder()
        self.presenter.confirmButtonWasPressedWithPassword(password: passwordTextfield.text!)
    }
    
    
    @IBAction func showPasswordButtonWasPressed(_ sender: Any) {
        self.presenter.showPasswordWasPressed()
    }
    
    
    @IBAction func passwordFieldEditingChanged(_ sender: Any) {
        if self.passwordTextfield.text == "" {
            self.presenter.passwordFieldIsEmpty()
        }
    }
    
    @objc func recoverLblWasPressed() {
        self.presenter.recoverPwdWasPressed()
    }
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        self.presenter.closeButtonWasPressed()
    }
}

extension SCDeleteAccountConfirmationViewController: SCDeleteAccountConfirmationDisplaying {
    func setupRecoverLoginBtn(title: String){
        self.recoverPasswordLabel.adaptFontSize();
        let recoverAttrString = NSMutableAttributedString(string: title)
        _ = recoverAttrString.setTextColor(textToFind:title, color: UIColor(named: "CLR_OSCA_BLUE")!)
        self.recoverPasswordLabel.attributedText = recoverAttrString
        self.recoverPasswordLabel.isUserInteractionEnabled = true
        
        let recoverTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.recoverLblWasPressed))
        recoverPasswordLabel.addGestureRecognizer(recoverTapGesture)
    }
    
    func setupNavigationBar(title: String, backTitle: String) {
        self.navigationItem.title = title
        self.navigationItem.backBarButtonItem?.title = backTitle
    }
    
    func setupTitleLabel(title: String) {
        self.titleLabel.adaptFontSize()
        self.titleLabel.text = title
        
        titleLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 17, maxSize: nil)
    }
    
    func setupPasswordField(title: String) {
        let fontSize : CGFloat = self.passwordTextfield.font?.pointSize ?? 0.0
        
        self.passwordTextfield.textColor = UIColor(named: "CLR_LABEL_TEXT_BLACK")!
        self.passwordTextfield.textColor = UIColor(named: "CLR_LABEL_TEXT_BLACK")!
        self.passwordTextfield.clearsOnBeginEditing = true
        self.passwordTextfield.isSecureTextEntry = true
        self.passwordTextfield.textContentType = .password
        self.passwordTextfield.keyboardType = .asciiCapable
        self.passwordTextfield.delegate = self
        self.passwordErrorLabel.adaptFontSize()
        self.hidePWDError()
        self.passwordTextFieldTitleLabel.adaptFontSize()
        self.passwordTextFieldTitleLabel.textColor = .lightGray
        self.passwordTextFieldTitleLabel.text = title
        self.passwordTextfield.attributedPlaceholder = NSAttributedString(string: title, attributes: [
            .foregroundColor: UIColor.lightGray,
            .font: UIFont.boldSystemFont(ofSize: fontSize - 3.0)
            ])
    }
    
    func setupPasswordErrorLabel(title: String) {
        self.passwordErrorLabel.text = title
        self.passwordErrorLabel.textColor = UIColor(named: "CLR_LABEL_TEXT_RED")!
    }
    
    func setupConfirmationButton(title: String) {
        self.deleteAccountConfirmationButton.setTitle(title, for: .normal)
        self.deleteAccountConfirmationButton.customizeBlueStyle()
    }
    
    func showPasswordSelected(_ selected: Bool) {
        if selected {
            self.showPasswordButton?.setImage(UIImage(named: "icon_showpass_selected")?.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!), for: .normal)
            self.passwordTextfield?.isSecureTextEntry = false
        } else {
            self.showPasswordButton?.setImage(UIImage(named: "icon_showpass_unselected")?.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!), for: .normal)
            self.passwordTextfield?.isSecureTextEntry = true
        }
    }
    
    func hidePWDError() {
        self.passwordErrorLabel.isHidden = true
        self.validationIconWidthConstraint.constant = 0
        self.baselineView.backgroundColor = .lightGray
    }
    
    func showTopLabel() {
        self.passwordTextFieldTitleLabel.isHidden = false
    }
    
    func hideTopLabel() {
        self.passwordTextFieldTitleLabel.isHidden = true
    }
    
    func showPasswordIncorrectLabel() {
        self.passwordErrorLabel.isHidden = false
        self.baselineView.backgroundColor = UIColor(named: "CLR_LABEL_TEXT_RED")!
        self.validationIconWidthConstraint.constant = 31
    }
    
    func passwordTextfieldResignFirstResponder() {
        self.passwordTextfield.resignFirstResponder()
    }
    
    func presentOnTop(viewController: UIViewController, completion: (() -> Void)? = nil) {
        SCUtilities.topViewController().present(viewController, animated: true, completion: completion)
    }
    
    func popToRootViewController() {
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    func push(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func setConfirmButtonState(_ state : SCCustomButtonState){
        self.deleteAccountConfirmationButton.btnState = state
    }
    
    func confirmButtonState() -> SCCustomButtonState {
        return self.deleteAccountConfirmationButton.btnState
    }

    func dismiss(completion: (() -> Void)?) {
        self.dismiss(animated: true, completion: completion)
    }
}

extension SCDeleteAccountConfirmationViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.presenter.passwordFieldDidBeginEditing() //--> hide error label on display
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string == " ") { return false }
        
        guard string == "" &&  textField.text!.count == range.length else {
            self.presenter.passwordFieldHasText()
            return true
        }
        self.presenter.passwordFieldIsEmpty()
        return true
    }
    
}
