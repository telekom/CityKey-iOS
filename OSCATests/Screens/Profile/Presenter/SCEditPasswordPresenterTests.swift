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
//  SCEditPasswordPresenterTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 13/06/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

class SCEditPasswordPresenterTests: XCTestCase {
    
    private var editPwdPresenter: SCEditPasswordPresenting!
    private var editPwdDisplayer: SCEditPasswordDisplaying!
    
    private func prepareSut(editPasswordWorker: SCEditPasswordWorking? = nil) -> SCEditPasswordPresenter {
        return SCEditPasswordPresenter(email: "test@test.com",
                                       editPasswordWorker: editPasswordWorker ?? SCEditPasswordWorkerMock(),
                                       injector: MockSCInjector())
    }
    
    func testViewDidLoad() {
        let sut = prepareSut()
        let displayer = SCEditPasswordDisplayer()
        editPwdDisplayer = displayer
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        XCTAssertEqual("p_001_profile_label_account_settings".localized(), displayer.navigationTitle)
    }
    
    func testPasswordMinCharReachedFalse() {
        let sut = prepareSut()
        let displayer = SCEditPasswordDisplayer()
        editPwdDisplayer = displayer
        displayer.newPwd1Content = "test"
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        let isMinReached = sut.passwordMinCharReached()
        XCTAssertFalse(isMinReached)
    }
    
    func testPasswordMinCharReachedTrue() {
        let sut = prepareSut()
        let displayer = SCEditPasswordDisplayer()
        editPwdDisplayer = displayer
        displayer.newPwd1Content = "test@123"
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        let isMinReached = sut.passwordMinCharReached()
        XCTAssertTrue(isMinReached)
    }
    
    func testPasswordContainsSymbolFalse() {
        let sut = prepareSut()
        let displayer = SCEditPasswordDisplayer()
        editPwdDisplayer = displayer
        displayer.newPwd1Content = "test123"
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        let isContainsSymbol = sut.passwordContainsSymbol()
        XCTAssertFalse(isContainsSymbol)
    }
    
    func testPasswordContainsSymbolTrue() {
        let sut = prepareSut()
        let displayer = SCEditPasswordDisplayer()
        editPwdDisplayer = displayer
        displayer.newPwd1Content = "test@123"
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        let isContainsSymbol = sut.passwordContainsSymbol()
        XCTAssertTrue(isContainsSymbol)
    }
    
    func testPasswordContainsDigitFalse() {
        let sut = prepareSut()
        let displayer = SCEditPasswordDisplayer()
        editPwdDisplayer = displayer
        displayer.newPwd1Content = "test@test"
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        let isContainsDigit = sut.passwordContainsDigit()
        XCTAssertFalse(isContainsDigit)
    }
    
    func testPasswordContainsDigitTrue() {
        let sut = prepareSut()
        let displayer = SCEditPasswordDisplayer()
        editPwdDisplayer = displayer
        displayer.newPwd1Content = "test@123"
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        let isContainsDigit = sut.passwordContainsDigit()
        XCTAssertTrue(isContainsDigit)
    }
    
    func testDidChangeTextFieldTrue() {
        let sut = prepareSut()
        let displayer = SCEditPasswordDisplayer()
        editPwdDisplayer = displayer
        displayer.newPwd1Content = "Test@123"
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        sut.didChangeTextField()
        XCTAssertTrue(displayer.isEnableNewPWD2)
    }
    
    func testDidChangeTextFieldFalse() {
        let sut = prepareSut()
        let displayer = SCEditPasswordDisplayer()
        editPwdDisplayer = displayer
        displayer.newPwd1Content = "Test"
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        sut.didChangeTextField()
        XCTAssertFalse(displayer.isEnableNewPWD2)
    }
    
    func testLiveCheckTextFieldsTrue() {
        let sut = prepareSut()
        let displayer = SCEditPasswordDisplayer()
        editPwdDisplayer = displayer
        displayer.newPwd1Content = "Test@123"
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        sut.liveCheckTextFields(checkPassFld2: true)
        XCTAssertTrue(displayer.isRefreshPwdCheckCalled)
    }
    
    func testLiveCheckTextFieldsFalse() {
        let sut = prepareSut()
        let displayer = SCEditPasswordDisplayer()
        editPwdDisplayer = displayer
        displayer.newPwd1Content = "Test"
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        sut.liveCheckTextFields(checkPassFld2: false)
        XCTAssertTrue(displayer.isRefreshPwdCheckCalled)
    }
    
    func testIsNewPWD1StartsWithNewPWD2False() {
        let sut = prepareSut()
        let displayer = SCEditPasswordDisplayer()
        editPwdDisplayer = displayer
        displayer.newPwd1Content = "Test"
        displayer.newPwd2Content = "Test@123"
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        let isSame = sut.isNewPWD1StartsWithNewPWD2()
        XCTAssertFalse(isSame)
    }

    func testValidateNewPasswordsWithSecondPwdEmpty() {
        let sut = prepareSut()
        let displayer = SCEditPasswordDisplayer()
        editPwdDisplayer = displayer
        displayer.newPwd1Content = "Test@123"
        displayer.newPwd2Content = ""
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        sut.validateNewPasswords()
        XCTAssertTrue(displayer.isHideNewPWD2Error)
    }
    
    func testValidateNewPasswordsWithEqual() {
        let sut = prepareSut()
        let displayer = SCEditPasswordDisplayer()
        editPwdDisplayer = displayer
        displayer.newPwd1Content = "Test@123"
        displayer.newPwd2Content = "Test@123"
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        sut.validateNewPasswords()
        XCTAssertTrue(displayer.isHideNewPWD2Error)
        XCTAssertTrue(displayer.isShowNewPWD2OK)
    }
    
    func testValidateNewPasswordsWithError() {
        let mockError = "p_005_profile_password_change_error_no_match".localized()
        let sut = prepareSut()
        let displayer = SCEditPasswordDisplayer()
        editPwdDisplayer = displayer
        displayer.newPwd1Content = "Test@123"
        displayer.newPwd2Content = "Test@143"
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        sut.validateNewPasswords()
        XCTAssertEqual(displayer.newPwdError, mockError)
    }
    
    func testPassword1EqualsPassword2False() {
        let sut = prepareSut()
        let displayer = SCEditPasswordDisplayer()
        editPwdDisplayer = displayer
        displayer.newPwd1Content = "Test@123"
        displayer.newPwd2Content = "Test@143"
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        let isEqual = sut.password1EqualsPassword2()
        XCTAssertFalse(isEqual)
    }
    func testPassword1EqualsPassword2True() {
        let sut = prepareSut()
        let displayer = SCEditPasswordDisplayer()
        editPwdDisplayer = displayer
        displayer.newPwd1Content = "Test@123"
        displayer.newPwd2Content = "Test@123"
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        let isEqual = sut.password1EqualsPassword2()
        XCTAssertTrue(isEqual)
    }
    
    func testConfirmWasPressedWithSuccessResponse() {
        let sut = prepareSut()
        let displayer = SCEditPasswordDisplayer()
        editPwdDisplayer = displayer
        displayer.newPwd1Content = "Test@123"
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        sut.confirmWasPressed()
        XCTAssertEqual(displayer.newPwd1Content, "Test@123")
        XCTAssertTrue(displayer.isPushCalled)
    }
    
    func testConfirmWasPressedWithFailureResponse() {
        let mockedError = SCWorkerError.fetchFailed(SCWorkerErrorDetails.init(message: "",
                                                                              errorCode: ""))
        let sut = prepareSut(editPasswordWorker: SCEditPasswordWorkerMock(error: mockedError))
        let displayer = SCEditPasswordDisplayer()
        editPwdDisplayer = displayer
        displayer.newPwd1Content = "Test@123"
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        sut.confirmWasPressed()
        XCTAssertEqual(displayer.newPwd1Content, "Test@123")
        XCTAssertFalse(displayer.isPushCalled)
    }
    
    func testForgotPWDWasPressed() {
        let sut = prepareSut()
        let displayer = SCEditPasswordDisplayer()
        editPwdDisplayer = displayer
        displayer.newPwd1Content = "Test@123"
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        sut.forgotPWDWasPressed()
    }
    
    
}

class SCEditPasswordWorkerMock: SCEditPasswordWorking {
    let error: SCWorkerError?
    init(error: SCWorkerError? = nil) {
        self.error = error
    }
    func changePassword(currentPassword: String, newPassword: String, completion: @escaping ((SCWorkerError?) -> ())) {
        completion(error)
    }
}

class SCEditPasswordDisplayer: SCEditPasswordDisplaying, SCPresenting {
    private(set) var isViewDidLoadCalled: Bool = false
    private(set) var navigationTitle: String = ""
    var newPwd1Content: String = ""
    var newPwd2Content: String = ""
    private(set) var isEnableNewPWD2: Bool = false
    private(set) var isRefreshPwdCheckCalled: Bool = false
    private(set) var isHideNewPWD2Error: Bool = false
    private(set) var isShowNewPWD2OK: Bool = false
    private(set) var newPwdError: String = ""
    private(set) var isPushCalled: Bool = false
    func viewDidLoad() {
        isViewDidLoadCalled = true
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
    
    func setupNavigationBar(title: String) {
        navigationTitle = title
    }
    
    func setupUI() {
        
    }
    
    func oldPWDContent() -> String? {
        return "123@test"
    }
    
    func newPWD1Content() -> String? {
        return newPwd1Content
    }
    
    func newPWD2Content() -> String? {
        return newPwd2Content
    }
    
    func showOldPWDError(message: String) {
        
    }
    
    func showOldPWDOK() {
        
    }
    
    func hideOldPWDError() {
        
    }
    
    func showNewPWD1Error(message: String) {
        newPwdError = "p_005_profile_password_change_error_no_match".localized()
    }
    
    func showNewPWD1OK(message: String?) {
        
    }
    
    func hideNewPWD1Error() {
        
    }
    
    func showNewPWD2Error(message: String) {
        newPwdError = "p_005_profile_password_change_error_no_match".localized()
    }
    
    func showNewPWD2OK() {
        isShowNewPWD2OK = true
    }
    
    func hideNewPWD2Error() {
        isHideNewPWD2Error = true
    }
    
    func deleteContentNewPWD2() {
        
    }
    
    func enableNewPWD2(_ enabled: Bool) {
        isEnableNewPWD2 = enabled
    }
    
    func enableAllFields(_ enabled: Bool) {
        
    }
    
    func refreshPWDCheck(charCount: Int, minCharReached: Bool, symbolAvailable: Bool, digitAvailable: Bool, showRedLineAnyway: Bool) {
        isRefreshPwdCheckCalled = true
    }
    
    func push(viewController: UIViewController) {
        isPushCalled = true
    }
    
    func setSubmitButtonState(_ state: SCCustomButtonState) {
        
    }
    
    func dismiss(completion: (() -> Void)?) {
        
    }
    
    func presentOnTop(viewController: UIViewController, completion: (() -> Void)?) {
        
    }
    
    
}
