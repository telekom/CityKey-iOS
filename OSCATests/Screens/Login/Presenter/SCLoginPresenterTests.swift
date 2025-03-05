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
//  SCLoginLogic.swift
//  SmartCityTests
//
//  Created by Robert Swoboda - Telekom on 18.04.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
import MapKit
@testable import OSCA

final class SCLoginPresenterTests: XCTestCase {
	
	private var displayer: SCLoginDisplaying?
	
    private func prepareSut(loginWorker: SCLoginWorking? = nil) -> SCLoginPresenting {
		return SCLoginPresenter(loginWorker: loginWorker ?? SCLoginWorkerMock(),
								userContentSharedWorker: SCUserContentSharedWorkerMock(),
								appContentSharedWorker: SCAppContentWorkerMock(),
								cityContentSharedWorker: SCCityContentSharedWorkerMock() ,
								injector: MockSCInjector(),
								refreshHandler: MockRefreshHandler())
	}
	
	func testViewDidLoad() {
        let mockNavigationTitle = "l_001_login_title".localized()
        let mockBackBtnTitle = ""
        let mockEmailTitle = "l_001_login_hint_email".localized()
        let mockLoginBtnTitle = "l_001_login_btn_login".localized()
        let mockRememberLoginBtnTitle = "l_001_login_checkbox_stay_loggedin".localized()
        let mockRegisterBtnTitle = "l_001_login_info_not_registered".localized()
        let mockLinkTitle = "l_001_login_btn_register".localized()
        let mockRecoverLoginTitle = "l_001_login_btn_forgot_password".localized()
        let mockEmailFieldTitle = "l_001_login_hint_email".localized()
        let mockPwdFieldTitle = "l_001_login_hint_password".localized()
        
		let sut = prepareSut()
        let displayer = SCLoginDisplayer()
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        XCTAssertEqual(mockNavigationTitle, displayer.navTitle)
        XCTAssertEqual(mockBackBtnTitle, displayer.backBtnTitle)
        XCTAssertEqual(mockEmailTitle, displayer.emailFieldTitle)
        XCTAssertEqual(mockLoginBtnTitle, displayer.loginBtnTitle)
        XCTAssertEqual(mockRememberLoginBtnTitle, displayer.rememberBtnTitle)
        XCTAssertEqual(mockRegisterBtnTitle, displayer.registerBtnTitle)
        XCTAssertEqual(mockLinkTitle, displayer.linkTitle)
        XCTAssertEqual(mockRecoverLoginTitle, displayer.recoverLoginBtnTitle)
        XCTAssertEqual(mockPwdFieldTitle, displayer.pwdFieldTitle)
        XCTAssertEqual(displayer.loginBtnState, .disabled)
	}
    
    func testViewDidLoadWithLogoutUserInitiated() {
        let mockInfoText = "l_001_login_hint_active_logout".localized()
        let mockLoginWorker = SCLoginWorkerMock(logoutReason: .initiatedByUser)
        let sut = prepareSut(loginWorker: mockLoginWorker)
        let displayer = SCLoginDisplayer()
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        XCTAssertTrue(displayer.isShowInfoTextCalled)
        XCTAssertEqual(displayer.showInfoTextMessage, mockInfoText)
        XCTAssertTrue(mockLoginWorker.isClearLogoutReasonCalled)
    }
    
    func testViewDidLoadWithLogoutUpdateSuccessful() {
        let mockLoginWorker = SCLoginWorkerMock(logoutReason: .updateSuccessful)
        let sut = prepareSut(loginWorker: mockLoginWorker)
        let displayer = SCLoginDisplayer()
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        XCTAssertTrue(displayer.isHideInfoTextCalled)
        XCTAssertTrue(mockLoginWorker.isClearLogoutReasonCalled)
    }
    
    func testViewDidLoadWithLogoutKmliNotChcked() {
        let mockInfoText = "l_001_login_hint_kmli_not_checked".localized()
        let mockLoginWorker = SCLoginWorkerMock(logoutReason: .kmliNotChcked)
        let sut = prepareSut(loginWorker: mockLoginWorker)
        let displayer = SCLoginDisplayer()
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        XCTAssertTrue(displayer.isShowInfoTextCalled)
        XCTAssertEqual(displayer.showInfoTextMessage, mockInfoText)
        XCTAssertTrue(mockLoginWorker.isClearLogoutReasonCalled)
    }
    
    func testViewDidLoadWithLogoutWasNotLoggedInBefore() {
        let mockLoginWorker = SCLoginWorkerMock(logoutReason: .wasNotLoggedInBefore)
        let sut = prepareSut(loginWorker: mockLoginWorker)
        let displayer = SCLoginDisplayer()
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        XCTAssertTrue(displayer.isHideInfoTextCalled)
        XCTAssertTrue(mockLoginWorker.isClearLogoutReasonCalled)
    }
    
    func testViewDidLoadWithTechnicalReason() {
        let mockInfoText = "l_001_login_hint_technical_logout".localized()
        let mockLoginWorker = SCLoginWorkerMock(logoutReason: .technicalReason)
        let sut = prepareSut(loginWorker: mockLoginWorker)
        let displayer = SCLoginDisplayer()
        sut.setDisplay(displayer)
        sut.viewDidLoad()
        XCTAssertTrue(displayer.isShowInfoTextCalled)
        XCTAssertEqual(displayer.showInfoTextMessage, mockInfoText)
        XCTAssertTrue(mockLoginWorker.isClearLogoutReasonCalled)
    }
    
    func testLoginToValidateCredentialsFailure() {
        let mockError = SCValidationResult(isValid: false,
                                           message: "l_001_login_error_fill_in".localized())
        let mockLoginWorker = SCLoginWorkerMock()
        let sut = prepareSut(loginWorker: mockLoginWorker)
        let displayer = SCLoginDisplayer(email: "test@email.com", pwd: "test@123")
        sut.setDisplay(displayer)
        sut.loginWasPressed()
        XCTAssertTrue(displayer.isHidePWDError)
        XCTAssertTrue(displayer.isHideEMailError)
        let loginFailureExpectation = expectation(description: "Test after 3 seconds")
        let result = XCTWaiter.wait(for: [loginFailureExpectation], timeout: 3.0)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertEqual(displayer.loginBtnState, .disabled)
        } else {
            XCTFail("Delay interrupted")
        }
    }
    
    func testLoginToValidateCredentials() {
        let mockError = SCValidationResult(isValid: false,
                                           message: "l_001_login_error_fill_in".localized())
        let mockLoginWorker = SCLoginWorkerMock()
        let sut = prepareSut(loginWorker: mockLoginWorker)
        let displayer = SCLoginDisplayer(email: "correct@email.com", pwd: "test@123")
        sut.setDisplay(displayer)
        sut.loginWasPressed()
        XCTAssertTrue(displayer.isHidePWDError)
        XCTAssertTrue(displayer.isHideEMailError)
        XCTAssertEqual(displayer.loginBtnState, .progress)
        let loginSuccessExpectation = expectation(description: "Test after 3 seconds")
        let result = XCTWaiter.wait(for: [loginSuccessExpectation], timeout: 3.0)
        if result == XCTWaiter.Result.timedOut {
            XCTAssertNotNil(displayer.navigationController())
        } else {
            XCTFail("Delay interrupted")
        }
    }
    
    func testRegisterWasPressed() {
        let mockLoginWorker = SCLoginWorkerMock()
        let sut = prepareSut(loginWorker: mockLoginWorker)
        let displayer = SCLoginDisplayer(email: "test@gmail.com", pwd: "test@123")
        sut.setDisplay(displayer)
        sut.registerWasPressed()
        XCTAssertTrue(displayer.isPresentOnTopCalled)
    }
    
    func testRememberLoginWasPressed() {
        let mockLoginWorker = SCLoginWorkerMock()
        let sut = prepareSut(loginWorker: mockLoginWorker)
        let displayer = SCLoginDisplayer(email: "test@gmail.com", pwd: "test@123")
        sut.setDisplay(displayer)
        sut.rememberLoginWasPressed()
        XCTAssertTrue(displayer.isShowRememberLoginSelected)
    }
    
    func testPwdShowPasswordWasPressed() {
        let mockLoginWorker = SCLoginWorkerMock()
        let sut = prepareSut(loginWorker: mockLoginWorker)
        let displayer = SCLoginDisplayer(email: "test@gmail.com", pwd: "test@123")
        sut.setDisplay(displayer)
        sut.pwdShowPasswordWasPressed()
        XCTAssertTrue(displayer.isShowPasswordWasPressed)
    }
    
    func testFeedbackWasPressed() {
        let sut = prepareSut()
        let displayer = SCLoginDisplayer()
        sut.setDisplay(displayer)
        sut.feedbackWasPressed()
        XCTAssertTrue(displayer.isPushCalled)
    }
    
    func testAccessibilityStatementButtonWasPressed() {
        let sut = prepareSut()
        let displayer = SCLoginDisplayer()
        sut.setDisplay(displayer)
        sut.accessibilityStatementButtonWasPressed()
        XCTAssertTrue(displayer.isPushCalled)
    }
    
    func testPresentPrivacy() {
        let sut = prepareSut()
        let displayer = SCLoginDisplayer()
        sut.setDisplay(displayer)
        sut.securityButtonWasPressed()
        XCTAssertTrue(displayer.isPushCalled)
    }
    
    func testDataPrivacySettingsButtonWasPressed() {
        let sut = prepareSut()
        let displayer = SCLoginDisplayer()
        sut.setDisplay(displayer)
        sut.dataPrivacySettingsButtonWasPressed()
        XCTAssertTrue(displayer.isPushCalled)
    }
    
    func testEMailFieldDidChange() {
        let sut = prepareSut()
        let displayer = SCLoginDisplayer(email: "test@gmail.com", pwd: "test@123")
        sut.setDisplay(displayer)
        sut.eMailFieldDidChange()
        XCTAssertTrue(displayer.isHidePWDError)
        XCTAssertTrue(displayer.isHideEMailError)
        XCTAssertTrue(displayer.isRefreshTopPlaceholderLabelCalled)
    }
    
    func testPasswordFieldDidChange() {
        let sut = prepareSut()
        let displayer = SCLoginDisplayer(email: "test@gmail.com", pwd: "test@123")
        sut.setDisplay(displayer)
        sut.passwordFieldDidChange()
        XCTAssertTrue(displayer.isHidePWDError)
        XCTAssertTrue(displayer.isHideEMailError)
        XCTAssertTrue(displayer.isRefreshTopPlaceholderLabelCalled)
    }
    
    func testIsLoginRemembered() {
        let sut = prepareSut()
        let displayer = SCLoginDisplayer(email: "test@gmail.com", pwd: "test@123")
        sut.setDisplay(displayer)
        let isRemembered = sut.isLoginRemembered()
        XCTAssertFalse(isRemembered)
        sut.rememberLoginWasPressed()
        XCTAssertTrue(sut.isLoginRemembered())
        
    }
    
    func testSoftwareLicensekWasPressed() {
        let sut = prepareSut()
        let displayer = SCLoginDisplayer(email: "test@gmail.com", pwd: "test@123")
        sut.setDisplay(displayer)
        sut.softwareLicensekWasPressed()
        XCTAssertTrue(displayer.isPushCalled)
    }
    
    func testCancelWasPressed() {
        let sut = prepareSut()
        let displayer = SCLoginDisplayer(email: "test@gmail.com", pwd: "test@123")
        sut.setDisplay(displayer)
        sut.cancelWasPressed()
        XCTAssertNotNil(displayer.navigationController())
    }

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        SCAuth.shared.removeAuthorization()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        SCAuth.shared.removeAuthorization()
    }

    
    func testValidateCredentails() {
        let presenter = SCLoginPresenter(loginWorker: SCLoginWorkerMock(),
                                         userContentSharedWorker: SCUserContentSharedWorkerMock(),
                                         appContentSharedWorker: SCAppContentWorkerMock(),
                                         cityContentSharedWorker: SCCityContentSharedWorkerMock() ,
                                         injector: MockSCInjector(),
                                         refreshHandler: MockRefreshHandler())
        
        let resultBothEmpty = presenter.validateCredentials(email: "", password: "")
        XCTAssertFalse(resultBothEmpty.emailResult?.isValid ?? true)
        XCTAssertFalse(resultBothEmpty.passwordResult?.isValid ?? true)
        XCTAssertFalse(resultBothEmpty.allValid)
    }
    
    /*
    func testLoginCorrect() {
        let presenter = SCLoginPresenter(loginWorker: MockLoginWorker(), injector: MockInjector())

        let loginSuccessfulExpectation = expectation(description: "login successful")

        presenter. login(email: "correct@email.com", password: "password correct", remember: false) { (loginError) in
            XCTAssertNil(loginError)
            
            loginSuccessfulExpectation.fulfill()
         }
        wait(for: [loginSuccessfulExpectation], timeout: 1)
    }
    
    func testLoginWrong() {
        let presenter = SCLoginPresenter(loginWorker: MockLoginWorker(), injector: MockInjector())
        
        let loginSuccessfulExpectation = expectation(description: "login successful")
        
        presenter.login(email: "wrong@email.com", password: "password correct", remember: false) { (loginError) in
            
            XCTAssertNotNil(loginError)
           
            loginSuccessfulExpectation.fulfill()
        }
        wait(for: [loginSuccessfulExpectation], timeout: 1)
    }*/
}

final class SCLoginDisplayer: SCLoginDisplaying {
    
    private(set) var loginBtnState: SCCustomButtonState = .normal
    private(set) var navTitle: String = ""
    private(set) var backBtnTitle: String = ""
    private(set) var loginBtnTitle: String = ""
    private(set) var rememberBtnTitle: String = ""
    private(set) var registerBtnTitle: String = ""
    private(set) var linkTitle: String = ""
    private(set) var recoverLoginBtnTitle: String = ""
    private(set) var emailFieldTitle: String = ""
    private(set) var pwdFieldTitle: String = ""
    private(set) var isShowInfoTextCalled: Bool = false
    private(set) var showInfoTextMessage: String = ""
    private(set) var isHideInfoTextCalled: Bool = false
    private(set) var isHidePWDError: Bool = false
    private(set) var isHideEMailError: Bool = false
    private(set) var emailErrorMsg: String = ""
    private(set) var pWDErrorMsg: String = ""
    private(set) var isPresentOnTopCalled: Bool = false
    private(set) var isShowRememberLoginSelected: Bool = false
    private(set) var isShowPasswordWasPressed: Bool = false
    private(set) var isPushCalled: Bool = false
    private(set) var isRefreshTopPlaceholderLabelCalled: Bool = false
    
    let email: String?
    let pwd: String?
    
    init(email: String? = nil, pwd: String? = nil) {
        self.email = email
        self.pwd = pwd
    }
    
    
	func setupNavigationBar(title: String, backTitle: String) {
		navTitle = title
        backBtnTitle = backTitle
	}
	
	func setupLoginBtn(title: String) {
		loginBtnTitle = title
	}
	
	func setupRememberLoginBtn(title: String) {
        rememberBtnTitle = title
	}
	
	func setupRegisterBtn(title: String, linkTitle: String) {
		registerBtnTitle = title
        self.linkTitle = linkTitle
	}
	
	func setupRecoverLoginBtn(title: String) {
        recoverLoginBtnTitle = title
	}
	
	func setupEMailField(title: String) {
        emailFieldTitle = title
	}
	
	func setupPasswordField(title: String) {
		pwdFieldTitle = title
	}
	
	func refreshTopPlaceholderLabel() {
		isRefreshTopPlaceholderLabelCalled = true
	}
	
	func showPWDError(message: String) {
        pWDErrorMsg = message
	}
	
	func hidePWDError() {
		isHidePWDError = true
	}
	
	func showEMailError(message: String) {
        emailErrorMsg = message
	}
	
	func hideEMailError() {
		isHideEMailError = true
	}
	
	func showInfoText(message: String) {
        showInfoTextMessage = message
        isShowInfoTextCalled = true
	}
	
	func hideInfoText() {
        isHideInfoTextCalled = true
	}
	
	func showPasswordSelected(_ selected: Bool) {
        isShowPasswordWasPressed = true
	}
	
	func showRememberLoginSelected(_ selected: Bool) {
        isShowRememberLoginSelected = true
	}
	
	func eMailFieldContent() -> String? {
		return email
	}
	
	func pwdFieldContent() -> String? {
        return pwd
	}
	
	func presentOnTop(viewController: UIViewController, completion: (() -> Void)?) {
		isPresentOnTopCalled = true
        completion?()
	}
	
	func present(viewController: UIViewController) {
		
	}
	
	func push(viewController: UIViewController) {
		isPushCalled = true
	}
	
	func navigationController() -> UINavigationController? {
		UINavigationController()
	}
	
	func passwordFieldMaxLenght(_ lenght: Int) {
		
	}
	
	func eMailFieldMaxLenght(_ lenght: Int) {
		
	}
	
	func setLoginButtonState(_ state: OSCA.SCCustomButtonState) {
        loginBtnState = state
	}
    
    func loginButtonState() -> OSCA.SCCustomButtonState {
        return loginBtnState
    }
}
