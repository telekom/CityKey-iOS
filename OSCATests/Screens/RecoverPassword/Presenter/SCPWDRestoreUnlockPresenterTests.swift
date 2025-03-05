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
//  SCPWDRestoreUnlockPresenterTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 09/07/24.
//  Copyright © 2024 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

final class SCPWDRestoreUnlockPresenterTests: XCTestCase {
    
    weak private var display : SCPWDRestoreUnlockDisplaying?
    
    private func prepareSut(screenType: SCPWDRestoreUnlockVCType = .pwdForgotten,
                            restoreUnlockWorker: SCPWDRestoreUnlockWorking? = nil) -> SCPWDRestoreUnlockPresenting {
        return SCPWDRestoreUnlockPresenter(email: "correct@email.com",
                                           screenType: screenType,
                                           restoreUnlockWorker: restoreUnlockWorker ?? SCPWDRestoreUnlockWorkerMock(),
                                           injector: MockSCInjector(),
                                           completionOnSuccess: nil)
    }
    
    func testSetupUIForPwdForget() {
        let screenType = SCPWDRestoreUnlockVCType.pwdForgotten
        let detail = "f_001_forgot_password_info_click_link".localized()
        let navigationTitle = "f_001_forgot_password_btn_reset_password".localized()
        let iconName = "icon_reset_password"
        let sut = prepareSut(screenType: screenType)
        let displayer = SCPWDRestoreUnlockDisplayer()
        self.display = displayer
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        XCTAssertTrue(displayer.isSetupUICalled)
        XCTAssertEqual(detail, displayer.detail)
        XCTAssertEqual(navigationTitle, displayer.screenTitle)
        XCTAssertEqual(iconName, displayer.iconName)
        XCTAssertEqual("correct@email.com", displayer.defaultEmail)
    }
    
    func testSetupUIForPwdLocked() {
        let screenType = SCPWDRestoreUnlockVCType.pwdLocked
        let detail = "f_001_forgot_password_info_locked_account".localized()
        let navigationTitle = "l_002_login_locked_account_title".localized()
        let iconName = "icon_account_locked"
        let sut = prepareSut(screenType: screenType)
        let displayer = SCPWDRestoreUnlockDisplayer()
        self.display = displayer
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        XCTAssertTrue(displayer.isSetupUICalled)
        XCTAssertEqual(detail, displayer.detail)
        XCTAssertEqual(navigationTitle, displayer.screenTitle)
        XCTAssertEqual(iconName, displayer.iconName)
        XCTAssertEqual("correct@email.com", displayer.defaultEmail)
    }
    
    func testPwdRecoverySuccess() {
        let sut = prepareSut(restoreUnlockWorker: SCPWDRestoreUnlockWorkerMock(isSuccess: true))
        let displayer = SCPWDRestoreUnlockDisplayer()
        self.display = displayer
        sut.setDisplay(displayer)
        sut.recoveryWasPressed()
        let recoverSuccessExpectation = expectation(description: "PWD recovery success")
        let result = XCTWaiter.wait(for: [recoverSuccessExpectation], timeout: 1.0)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(displayer.isDismissKeyboard)
            XCTAssertEqual(displayer.state, .disabled)
            XCTAssertEqual(displayer.inputField, .email)
            XCTAssertEqual(displayer.updatedValidationState, .ok)
        } else {
            XCTFail("Delay interrupted")
        }
    }
    
    func testPwdRecoveryFailure() {
        let sut = prepareSut(restoreUnlockWorker: SCPWDRestoreUnlockWorkerMock(isSuccess: false))
        let displayer = SCPWDRestoreUnlockDisplayer()
        self.display = displayer
        sut.setDisplay(displayer)
        sut.recoveryWasPressed()
        let recoverFailureExpectation = expectation(description: "PWD recovery failure")
        let result = XCTWaiter.wait(for: [recoverFailureExpectation], timeout: 1.0)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertTrue(displayer.isDismissKeyboard)
            XCTAssertEqual(displayer.state, .disabled)
        } else {
            XCTFail("Delay interrupted")
        }
    }
    
    func testTextFieldComponentDidChange() {
        let sut = prepareSut()
        let displayer = SCPWDRestoreUnlockDisplayer()
        self.display = displayer
        sut.setDisplay(displayer)
        let inputField = SCPWDRestoreUnlockInputFields.pwd1
        sut.textFieldComponentDidChange(for: inputField)
        XCTAssertEqual(displayer.inputField, .pwd2)
        
        let emailInputField = SCPWDRestoreUnlockInputFields.email
        sut.textFieldComponentDidChange(for: inputField)
        XCTAssertEqual(displayer.state, .normal)
    }
    
    func testEmailTextFieldEndEditing() {
        let sut = prepareSut()
        let displayer = SCPWDRestoreUnlockDisplayer()
        self.display = displayer
        sut.setDisplay(displayer)
        sut.txtFieldEditingDidEnd(value: "test@gmail.com", inputField: .email, textFieldType: .email)
        XCTAssertEqual(displayer.inputField, .email)
        XCTAssertEqual(displayer.updatedValidationState, .unmarked)
    }
    
    func testWrongEmailTextFieldEndEditing() {
        let sut = prepareSut()
        let displayer = SCPWDRestoreUnlockDisplayer()
        self.display = displayer
        sut.setDisplay(displayer)
        sut.txtFieldEditingDidEnd(value: "test@gmail", inputField: .email, textFieldType: .email)
        XCTAssertEqual(displayer.inputField, .email)
        XCTAssertEqual(displayer.updatedValidationState, .wrong)
    }
    
    func testCancelWasPressed() {
        let sut = prepareSut(screenType: .pwdLocked)
        let displayer = SCPWDRestoreUnlockDisplayer()
        self.display = displayer
        sut.setDisplay(displayer)
        sut.cancelWasPressed()
        XCTAssertTrue(displayer.isDismissViewCalled)
    }
    
    func testConfigureField() {
        let sut = prepareSut(screenType: .pwdLocked)
        let displayer = SCPWDRestoreUnlockDisplayer()
        self.display = displayer
        sut.setDisplay(displayer)
        let emailTextField = sut.configureField(SCTextfieldComponent(), identifier: "sgtxtfldEmail",
                                                type: .email, autocapitalizationType: .none)
        XCTAssertNotNil(emailTextField)
    }
}

class SCPWDRestoreUnlockDisplayer: SCPWDRestoreUnlockDisplaying {
    
    private(set) var screenTitle: String = ""
    private(set) var detail: String = ""
    private(set) var iconName: String = ""
    private(set) var btnText: String = ""
    private(set) var defaultEmail: String = ""
    private(set) var isSetupUICalled: Bool = false
    private(set) var state: SCCustomButtonState = .normal
    private(set) var isDismissKeyboard: Bool = false
    private(set) var updatedValidationState: SCTextfieldValidationState = .wrong
    private(set) var inputField: SCPWDRestoreUnlockInputFields = .pwd1
    private(set) var isShowErrorDialogCalled: Bool = false
    private(set) var errorMsg: String = ""
    private(set) var msg: String = ""
    private(set) var isDismissViewCalled: Bool = false
    
    func setupNavigationBar(title: String, backTitle: String) {
        
    }
    
    func setupUI() {
        isSetupUICalled = true
    }
    
    func refreshUI(screenTitle: String, detail: String, iconName: String, btnText: String, defaultEmail: String) {
        self.screenTitle = screenTitle
        self.detail = detail
        self.iconName = iconName
        self.btnText = btnText
        self.defaultEmail = defaultEmail
    }
    
    func getValue(for inputField: OSCA.SCPWDRestoreUnlockInputFields) -> String? {
        switch inputField {
        case .pwd1, .pwd2:
            return "test@123"
        case .email:
            return "correct@email.com"
        }
    }
    
    func getFieldType(for inputField: OSCA.SCPWDRestoreUnlockInputFields) -> OSCA.SCTextfieldComponentType {
        return SCTextfieldComponentType.birthdate
    }
    
    func hideError(for inputField: OSCA.SCPWDRestoreUnlockInputFields) {
        self.inputField = inputField
    }
    
    func showError(for inputField: OSCA.SCPWDRestoreUnlockInputFields, text: String) {
        self.inputField = inputField
        errorMsg = text
    }
    
    func showMessagse(for inputField: OSCA.SCPWDRestoreUnlockInputFields, text: String, color: UIColor) {
        self.inputField = inputField
        msg = text
    }
    
    func deleteContent(for inputField: OSCA.SCPWDRestoreUnlockInputFields) {
        self.inputField = inputField
    }
    
    func updateValidationState(for inputField: OSCA.SCPWDRestoreUnlockInputFields, state: OSCA.SCTextfieldValidationState) {
        updatedValidationState = state
        self.inputField = inputField
    
    }
    
    func getValidationState(for inputField: OSCA.SCPWDRestoreUnlockInputFields) -> OSCA.SCTextfieldValidationState {
        return SCTextfieldValidationState.ok
    }
    
    func setEnable(for inputField: OSCA.SCPWDRestoreUnlockInputFields, enabled: Bool) {
        
    }
    
    func dismissKeyboard() {
        isDismissKeyboard = true
    }
    
    func updatePWDChecker(charCount: Int, minCharReached: Bool, symbolAvailable: Bool, digitAvailable: Bool) {
        
    }
    
    func dismissView(animated flag: Bool, completion: (() -> Void)?) {
        isDismissViewCalled = true
    }
    
    func overlay(viewController: UIViewController, title: String) {
        
    }
    
    func setRecoverButtonState(_ state: OSCA.SCCustomButtonState) {
        self.state = state
    }
    
    func recoverButtonState() -> OSCA.SCCustomButtonState {
        return SCCustomButtonState.progress
    }
    
    func showErrorDialog(_ error: SCWorkerError, retryHandler : (() -> Void)? = nil, showCancelButton: Bool? = true, additionalButtonTitle: String? = nil, additionButtonHandler: (() -> Void)? = nil) {
        isShowErrorDialogCalled = true
    }
}

class SCPWDRestoreUnlockWorkerMock: SCPWDRestoreUnlockWorking {
    let isSuccess: Bool
    init(isSuccess: Bool = false) {
        self.isSuccess = isSuccess
    }
    func recoverPassword(_ email: String, pwd: String, completion: @escaping ((Bool, OSCA.SCWorkerError?) -> Void)) {
        if isSuccess {
            completion(true, nil)
        } else {
            let mockedError = SCWorkerError.fetchFailed(SCWorkerErrorDetails.init(message: "",
                                                                                  errorCode: ""))
            completion(false, mockedError)
        }
    }
}
