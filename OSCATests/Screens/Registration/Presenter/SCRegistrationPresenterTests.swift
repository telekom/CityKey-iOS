/*
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*///
//  SCRegistrationPresenterTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 02/07/24.
//  Copyright © 2024 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

final class SCRegistrationPresenterTests: XCTestCase {
    
    private var registrationDisplayer: SCRegistrationDisplaying!
    
    private func prepareSut(worker: SCRegistrationWorking? = nil, appContentSharedWorker: SCAppContentSharedWorking? = nil) -> SCRegistrationPresenting {
        
        let displayer: SCRegistrationDisplaying = SCRegistrationDisplayer()
        let presenter = SCRegistrationPresenter(registrationWorker: worker ?? SCRegistrationWorkerMock(),
                                       appContentSharedWorker: appContentSharedWorker ?? SCAppContentSharedWorker(requestFactory: SCRequestMock()),
                                       injector: MockSCInjector(),
                                       completionOnSuccess: nil)
        presenter.setDisplay(displayer)
        return presenter
    }
    
    func testSetupUI() {
        let sut = prepareSut()
        let displayer = SCRegistrationDisplayer()
        self.registrationDisplayer = displayer
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        XCTAssertEqual(displayer.submitBtnState, SCCustomButtonState.disabled)
        XCTAssertEqual(displayer.submitBtnTitle, "r_001_registration_btn_register".localized())
        XCTAssertEqual(displayer.navTitle, "r_001_registration_title".localized())
        XCTAssertEqual(displayer.backTitle, "")
        XCTAssertEqual(displayer.disAllowedPwdChar, " ")
        XCTAssertEqual(displayer.disAllowedEmailChar, " ")
    }
    
    func testConfigureField() {
        let sut = prepareSut()
        let mockTextField = MockTextField()
        sut.configureField(mockTextField, identifier: "sgtxtfldEmail", type: .email, autocapitalizationType: .none)
        XCTAssertEqual(mockTextField.placeholderText, "r_001_registration_hint_email".localized())
        XCTAssertEqual(mockTextField.maxCharCount, 255)
        XCTAssertEqual(mockTextField.textFieldType, .email)
        
        sut.configureField(mockTextField, identifier: "sgtxtfldPwd1", type: .pwd1, autocapitalizationType: .none)
        XCTAssertEqual(mockTextField.placeholderText, 
                       "r_001_registration_hint_password".localized())
        XCTAssertEqual(mockTextField.maxCharCount, 255)
        XCTAssertEqual(mockTextField.textFieldType, .newPassword)
        
        sut.configureField(mockTextField, identifier: "sgtxtfldPwd2", type: .pwd2, autocapitalizationType: .none)
        XCTAssertEqual(mockTextField.placeholderText, "r_001_registration_hint_password_repeat".localized())
        XCTAssertEqual(mockTextField.maxCharCount, 255)
        XCTAssertEqual(mockTextField.textFieldType, .newPassword)
        
        sut.configureField(mockTextField, identifier: "sgtxtfldBirthdate", type: .birthdate, autocapitalizationType: .none)
        XCTAssertEqual(mockTextField.placeholderText, "r_001_registration_hint_birthday".localized())
        XCTAssertEqual(mockTextField.maxCharCount, 10)
        XCTAssertEqual(mockTextField.textFieldType, .birthdate)
        
        sut.configureField(mockTextField, identifier: "sgtxtfldPostalCode", type: .postalCode, autocapitalizationType: .none)
        XCTAssertEqual(mockTextField.placeholderText, "r_001_registration_hint_postcode".localized())
        XCTAssertEqual(mockTextField.maxCharCount, 5)
        XCTAssertEqual(mockTextField.textFieldType, .postalCode)
    }
    
    func testRegistrationSuccess() {
        let worker = SCRegistrationWorkerMock(isRegistrationSuccess: true)
        let sut = prepareSut(worker: worker)
        let displayer = SCRegistrationDisplayer()
        self.registrationDisplayer = displayer
        sut.setDisplay(displayer)
        sut.privacyWasPressed()
        sut.submitWasPressed()
        XCTAssertTrue(displayer.isHideErrorCalled)
        XCTAssertTrue(displayer.updatePrivacyValidationCalled)
        XCTAssertTrue(displayer.privacyAcceptedStatus)
        let registrationSuccessExpectation = expectation(description: "Test after 3 seconds")
        let result = XCTWaiter.wait(for: [registrationSuccessExpectation], timeout: 3.0)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(displayer.submitBtnState, .disabled)
            XCTAssertEqual(displayer.validatationState, .ok)
            XCTAssertEqual(displayer.inputField, .postalCode)
            XCTAssertEqual(displayer.showMsg, "Musterstadt,Model State is supported!")
        } else {
            XCTFail("Delay interrupted")
        }
    }
    
    func testRegistrationFailure() {
        let errorDetails = SCWorkerErrorDetails(message: "E-mail already in use.", errorCode: "user.email.exists")
        let mockError: SCWorkerError = SCWorkerError.fetchFailed(errorDetails)
        let worker = SCRegistrationWorkerMock(isRegistrationSuccess: false, error: mockError)
        let sut = prepareSut(worker: worker)
        let displayer = SCRegistrationDisplayer()
        self.registrationDisplayer = displayer
        sut.setDisplay(displayer)
        sut.privacyWasPressed()
        sut.submitWasPressed()
        XCTAssertTrue(displayer.isHideErrorCalled)
        XCTAssertTrue(displayer.updatePrivacyValidationCalled)
        XCTAssertTrue(displayer.privacyAcceptedStatus)
        let registrationSuccessExpectation = expectation(description: "Test after 3 seconds")
        let result = XCTWaiter.wait(for: [registrationSuccessExpectation], timeout: 3.0)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(displayer.showErrorMsg, errorDetails.message)
        } else {
            XCTFail("Delay interrupted")
        }
    }
    
    func testPrivacyWasPressed() {
        let sut = prepareSut()
        let displayer = SCRegistrationDisplayer()
        self.registrationDisplayer = displayer
        sut.setDisplay(displayer)
        sut.privacyWasPressed()
        XCTAssertTrue(displayer.updatePrivacyValidationCalled)
        XCTAssertTrue(displayer.privacyAcceptedStatus)
    }
    
    func testCloseWasPressed() {
        let sut = prepareSut()
        let displayer = SCRegistrationDisplayer()
        self.registrationDisplayer = displayer
        sut.setDisplay(displayer)
        sut.closeWasPressed()
        XCTAssertTrue(displayer.isDismissViewCalled)
    }
    
    func testDataPrivacyLinkWasPressed() {
        let sut = prepareSut()
        let displayer = SCRegistrationDisplayer()
        self.registrationDisplayer = displayer
        sut.setDisplay(displayer)
        sut.dataPrivacyLinkWasPressed()
        XCTAssertTrue(displayer.isPushCalled)
    }
    
    func testForStrongPwd() {
        let sut = prepareSut()
        let displayer = SCRegistrationDisplayer()
        self.registrationDisplayer = displayer
        sut.setDisplay(displayer)
        let pwdInputField = SCRegistrationInputFields.pwd1
        sut.textFieldComponentDidChange(for: pwdInputField)
        XCTAssertEqual(displayer.deletedContent, .pwd2)
        XCTAssertEqual(displayer.showMsg, "r_001_registration_hint_password_strong".localized())
        XCTAssertEqual(displayer.enableTextField, .pwd2)
    }
    
    func testForWeakPwd() {
        let sut = prepareSut()
        let displayer = SCRegistrationDisplayer(password1: "test", password2: "test")
        self.registrationDisplayer = displayer
        sut.setDisplay(displayer)
        let pwdInputField = SCRegistrationInputFields.pwd1
        sut.textFieldComponentDidChange(for: pwdInputField)
        XCTAssertEqual(displayer.deletedContent, .pwd2)
        XCTAssertEqual(displayer.showErrorMsg, "r_001_registration_error_password_too_weak".localized())
        XCTAssertEqual(displayer.enableTextField, .pwd2)
    }
    
    func testForPwdSameAsEMail() {
        let sut = prepareSut()
        let displayer = SCRegistrationDisplayer(password1: "test@gmail.com", password2: "test@gmail.com")
        self.registrationDisplayer = displayer
        sut.setDisplay(displayer)
        let pwdInputField = SCRegistrationInputFields.pwd1
        sut.textFieldComponentDidChange(for: pwdInputField)
        XCTAssertEqual(displayer.deletedContent, .pwd2)
        XCTAssertEqual(displayer.showErrorMsg, "r_001_registration_error_password_email_same".localized())
        XCTAssertEqual(displayer.enableTextField, .pwd2)
    }
    
    func testForEmptyPwd() {
        let sut = prepareSut()
        let displayer = SCRegistrationDisplayer(password1: "", password2: "")
        self.registrationDisplayer = displayer
        sut.setDisplay(displayer)
        let pwdInputField = SCRegistrationInputFields.pwd1
        sut.textFieldComponentDidChange(for: pwdInputField)
        XCTAssertEqual(displayer.deletedContent, .pwd2)
        XCTAssertTrue(displayer.isHideErrorCalled)
    }
    
    func testForDifferentPwd() {
        let sut = prepareSut()
        let displayer = SCRegistrationDisplayer(password1: "test@123", password2: "test@124")
        self.registrationDisplayer = displayer
        sut.setDisplay(displayer)
        let pwdInputField = SCRegistrationInputFields.pwd1
        sut.textFieldComponentDidChange(for: pwdInputField)
        XCTAssertEqual(displayer.deletedContent, .pwd2)
        XCTAssertEqual(displayer.showErrorMsg, "r_001_registration_error_password_no_match".localized())
    }
    
    func testTxtFieldEditingDidEnd() {
        let sut = prepareSut()
        let displayer = SCRegistrationDisplayer()
        self.registrationDisplayer = displayer
        sut.setDisplay(displayer)
        
        let emailInputField = SCRegistrationInputFields.email
        sut.txtFieldEditingDidEnd(value: "test@gmail", inputField: .email, textFieldType: .email)
        XCTAssertTrue(displayer.isHideErrorCalled)
        XCTAssertEqual(displayer.inputField, .email)
        XCTAssertEqual("r_001_registration_error_incorrect_email".localized(), displayer.showErrorMsg)
    }
    
}

fileprivate class MockTextField: SCTextFieldConfigurable {
    private(set) var identifier: String = ""
    private(set) var textFieldType: SCTextfieldComponentType = .text
    private(set) var maxCharCount: Int = 0
    private(set) var placeholderText: String = ""
    
    func configure(placeholder: String, fieldType: SCTextfieldComponentType, maxCharCount: Int, autocapitalization: UITextAutocapitalizationType) {
        placeholderText = placeholder
        textFieldType = fieldType
        self.maxCharCount = maxCharCount
    }
    
    func setEnabled(_ enabled: Bool) {
    }
    
}

class SCRegistrationDisplayer: SCRegistrationDisplaying {
    private(set) var submitBtnState: SCCustomButtonState = SCCustomButtonState.normal
    private(set) var submitBtnTitle: String = ""
    private(set) var navTitle: String = ""
    private(set) var backTitle: String = ""
    private(set) var disAllowedEmailChar: String = ""
    private(set) var disAllowedPwdChar: String = ""
    private(set) var isDismissKeyboardCalled: Bool = false
    private(set) var updatePrivacyValidationCalled: Bool = false
    private(set) var privacyAcceptedStatus: Bool = false
    private(set) var isDismissViewCalled: Bool = false
    private(set) var isPushCalled: Bool = false
    private(set) var showErrorDialogCalled: Bool = false
    private(set) var showMsg: String = ""
    private(set) var isHideErrorCalled: Bool = false
    private(set) var showErrorMsg: String = ""
    private(set) var inputField: OSCA.SCRegistrationInputFields?
    private(set) var dob: String?
    
    let password1: String
    let password2: String
    
    init(password1: String = "test@123", password2: String = "test@123") {
        self.password1 = password1
        self.password2 = password2
    }
    
    
    func setupNavigationBar(title: String, backTitle: String) {
        navTitle = title
        self.backTitle = backTitle
    }
    
    func setupUI(title: String) {
        submitBtnTitle = title
    }
    
    func setDisallowedCharacterForPassword(_ disallowedChars: String) {
        disAllowedPwdChar = disallowedChars
    }
    
    func setDisallowedCharacterForEMail(_ disallowedChars: String) {
        disAllowedEmailChar = disallowedChars
    }
    
    func dismissView(animated flag: Bool, completion: (() -> Void)?) {
        isDismissViewCalled = true
    }
    
    func dismissKeyboard() {
        isDismissKeyboardCalled = true
    }
    
    func setSubmitButtonState(_ state: OSCA.SCCustomButtonState) {
        submitBtnState = state
    }
    
    func getValue(for inputField: OSCA.SCRegistrationInputFields) -> String? {
        switch inputField {
        case .email:
            return "test@gmail.com"
        case .pwd1:
            return password1
        case .pwd2:
            return password2
        case .birthdate:
            return "10/11/1991"
        case .postalCode:
            return "11111"
        }
    }
    
    func getFieldType(for inputField: OSCA.SCRegistrationInputFields) -> OSCA.SCTextfieldComponentType {
        switch inputField {
        case .email:
            return .email
        case .pwd1:
            return .password
        case .pwd2:
            return .password
        case .birthdate:
            return .birthdate
        case .postalCode:
            return .postalCode
        }
    }
    
    func hideError(for inputField: OSCA.SCRegistrationInputFields) {
        isHideErrorCalled = true
    }
    
    func showError(for inputField: OSCA.SCRegistrationInputFields, text: String) {
        showErrorMsg = text
    }
    
    func showMessagse(for inputField: OSCA.SCRegistrationInputFields, text: String, color: UIColor) {
        showMsg = text
    }
    
    func scrollContent(to inputField: OSCA.SCRegistrationInputFields) {
        
    }
    
    private(set) var deletedContent: SCRegistrationInputFields?
    func deleteContent(for inputField: OSCA.SCRegistrationInputFields) {
        deletedContent = inputField
    }
    private(set) var validatationState: OSCA.SCTextfieldValidationState?
    func updateValidationState(for inputField: OSCA.SCRegistrationInputFields, state: OSCA.SCTextfieldValidationState) {
        self.inputField = inputField
        self.validatationState = state
    }
    
    func getValidationState(for inputField: OSCA.SCRegistrationInputFields) -> OSCA.SCTextfieldValidationState {
        return .ok
    }
    
    private(set) var enableTextField: SCRegistrationInputFields?
    func setEnable(for inputField: OSCA.SCRegistrationInputFields, enabled: Bool) {
        enableTextField = inputField
    }
    
    func updatePrivacyValidationState(_ accepted: Bool, showErrorInfoWhenNotAccepted: Bool) {
        updatePrivacyValidationCalled = true
        privacyAcceptedStatus = accepted
    }
    
    func updatePrivacyCheckbox(accepted: Bool) {
        
    }
    
    func updatePWDChecker(charCount: Int, minCharReached: Bool, symbolAvailable: Bool, digitAvailable: Bool) {
        
    }
    
    func overlay(viewController: UIViewController) {
        
    }
    
    func push(viewController: UIViewController) {
        isPushCalled = true
    }
    
    func present(viewController: UIViewController) {
        
    }
    
    func showErrorDialog(_ error: SCWorkerError, retryHandler : (() -> Void)? = nil, showCancelButton: Bool? = true, additionalButtonTitle: String? = nil, additionButtonHandler: (() -> Void)? = nil) {
        showErrorDialogCalled = true
    }
    
    func updateDobText(dob: String?) {
        self.dob = dob
    }
}


