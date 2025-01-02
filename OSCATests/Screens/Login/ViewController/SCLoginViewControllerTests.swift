//
//  SCLoginViewControllerTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 01/07/24.
//  Copyright © 2024 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

final class SCLoginViewControllerTests: XCTestCase {
    
    private func prepareSut(presenter: SCLoginPresenting? = nil) -> SCLoginViewController {
        let storyboard = UIStoryboard(name: "LoginScreen", bundle: nil)
        let sut = storyboard.instantiateViewController(identifier: "SCLoginViewController") as! SCLoginViewController
        sut.presenter = presenter ?? SCLoginPresenterMock()
        sut.loadViewIfNeeded()
        return sut
    }
    
    func testViewDidLoad() {
        let sut = prepareSut()
        sut.viewDidLoad()
        guard let presenter = sut.presenter as? SCLoginPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isViewDidLoadCalled)
        
    }
    
    func testViewWillAppear() {
        let sut = prepareSut()
        sut.viewWillAppear(true)
        guard let presenter = sut.presenter as? SCLoginPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isViewWillAppearCalled)
    }
    
    func testRegisterLblWasPressed() {
        let sut = prepareSut()
        sut.registerLblWasPressed()
        guard let presenter = sut.presenter as? SCLoginPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isRegisterWasPressed)
    }
    
    func testSetupNavigationBar() {
        let navTitle = "l_001_login_title".localized()
        let sut = prepareSut()
        sut.setupNavigationBar(title: navTitle, backTitle: "")
        XCTAssertEqual(sut.navigationItem.title, navTitle)
    }
    
    func testSetupLoginBtn() {
        let mockLoginTitle = "l_001_login_btn_login".localized()
        let sut = prepareSut()
        sut.setupLoginBtn(title: mockLoginTitle)
        XCTAssertEqual(sut.loginBtn.titleLabel?.text!, mockLoginTitle)
    }
    
    func testSetupRememberLoginBtn() {
        let title = "l_001_login_checkbox_stay_loggedin".localized()
        let sut = prepareSut()
        sut.setupRememberLoginBtn(title: title)
        XCTAssertEqual(sut.rememberLoginLabel.text, title)
    }
    
    func testSetupRegisterBtn() {
        let title = "l_001_login_info_not_registered".localized()
        let link = "www.google.com"
        let registerString = title + " " + link
        let attributedString = NSMutableAttributedString(string: registerString)
        _ = attributedString.setTextColor(textToFind:link, color: UIColor(named: "CLR_OSCA_BLUE")!)
        
        let sut = prepareSut()
        sut.setupRegisterBtn(title: title, linkTitle: link)
        
        XCTAssertEqual(sut.registerLabel.attributedText, attributedString)
    }
    
    func testSetupRecoverLoginBtn() {
        let btnTitle = "l_001_login_btn_forgot_password".localized()
        let recoverAttrString = NSMutableAttributedString(string: btnTitle)
        _ = recoverAttrString.setTextColor(textToFind: btnTitle, color: UIColor(named: "CLR_OSCA_BLUE")!)
        let sut = prepareSut()
        sut.setupRecoverLoginBtn(title: btnTitle)
        XCTAssertEqual(recoverAttrString, recoverAttrString)
    }
    
    func testSetupEMailField() {
        let emailTitle = "l_001_login_hint_email".localized()
        let sut = prepareSut()
        sut.setupEMailField(title: emailTitle)
        XCTAssertEqual(sut.eMailTopLabel.text, emailTitle)
        XCTAssertTrue(sut.eMailErrorLabel.isHidden)
    }
    
    func testCancelBtnWasPressed() {
        let sut = prepareSut()
        sut.cancelBtnWasPressed(UIButton())
        guard let presenter = sut.presenter as? SCLoginPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isCancelBtnWasPressed)
    }
    
    
    
    func testRememberLoginLblChecked() {
        let accessibilityValue = "accessibility_checkbox_state_checked".localized()
        let mockPresenter = SCLoginPresenterMock()
        mockPresenter.isLoginRememberedCalled = true
        let sut = prepareSut(presenter: mockPresenter)
        sut.rememberLoginLblWasPressed()
        guard let presenter = sut.presenter as? SCLoginPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isLoginRememberedCalled)
        XCTAssertEqual(accessibilityValue, sut.rememberLoginLabel.accessibilityValue)
    }
    
    func testRememberLoginLblUnChecked() {
        let accessibilityValue = "accessibility_checkbox_state_unchecked".localized()
        let mockPresenter = SCLoginPresenterMock()
        mockPresenter.isLoginRememberedCalled = false
        let sut = prepareSut(presenter: mockPresenter)
        sut.rememberLoginLblWasPressed()
        guard let presenter = sut.presenter as? SCLoginPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertFalse(presenter.isLoginRememberedCalled)
        XCTAssertEqual(accessibilityValue, sut.rememberLoginLabel.accessibilityValue)
    }
    
    func testRememberLoginBtnWasPressed() {
        let sut = prepareSut()
        sut.rememberLoginBtnWasPressed(UIButton())
        guard let presenter = sut.presenter as? SCLoginPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.rememberLoginCalled)
    }
    
    func testPedShowPasswordBtnWasPressed() {
        let sut = prepareSut()
        sut.pedShowPasswordBtnWasPressed(UIButton())
        guard let presenter = sut.presenter as? SCLoginPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isShowPwdCalled)
    }
    
    func testLoginBtnWasPressedWithRemembered() {
        let mockPresenter = SCLoginPresenterMock()
        mockPresenter.isLoginRememberedCalled = true
        let sut = prepareSut(presenter: mockPresenter)
        sut.loginBtnWasPressed(UIButton())
        guard let presenter = sut.presenter as? SCLoginPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isLoginWasPressed)
    }
    
    func testHelpFAQBtnWasPressed() {
        let sut = prepareSut()
        sut.helpFAQBtnWasPressed(UIButton())
        guard let presenter = sut.presenter as? SCLoginPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isHelpFAQWasPressed)
    }

    func testImprintBtnWasPressed() {
        let sut = prepareSut()
        sut.imprintBtnWasPressed(UIButton())
        guard let presenter = sut.presenter as? SCLoginPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isImprintButtonWasPressed)
    }
    
    func testSecurityBtnWasPressed() {
        let sut = prepareSut()
        sut.securityBtnWasPressed(UIButton())
        guard let presenter = sut.presenter as? SCLoginPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isSecurityButtonWasPressed)
    }

    func testAccessibilityStatementWasPressed() {
        let sut = prepareSut()
        sut.accessibilityStatementWasPressed(UIButton())
        guard let presenter = sut.presenter as? SCLoginPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isAccessibilityStatementButtonWasPressed)
    }
    
    func testFeedbackWasPressed() {
        let sut = prepareSut()
        sut.feedbackWasPressed(UIButton())
        guard let presenter = sut.presenter as? SCLoginPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isFeedbackWasPressed)
    }
    
    func testSoftwareLicenseWasPressed() {
        let sut = prepareSut()
        sut.softwareLicenseWasPressed(UIButton())
        guard let presenter = sut.presenter as? SCLoginPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isSoftwareLicensekWasPressed)
    }
    
    func testDataPrivacySettingsBtnWasPressed() {
        let sut = prepareSut()
        sut.dataPrivacySettingsBtnWasPressed(UIButton())
        guard let presenter = sut.presenter as? SCLoginPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isDataPrivacySettingsButtonWasPressed)
    }
    
    func testSetupPasswordField() {
        let title = "l_001_login_hint_password".localized()
        let sut = prepareSut()
        sut.setupPasswordField(title: title)
        guard let presenter = sut.presenter as? SCLoginPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertEqual(sut.pwdTopLabel.text, title)
        XCTAssertTrue(sut.pwdErrorLabel.isHidden)
    }
    
    func testShowEMailError() {
        let errorMsg = "mock error msg"
        let sut = prepareSut()
        sut.showEMailError(message: errorMsg)
        XCTAssertFalse(sut.eMailErrorLabel.isHidden)
        XCTAssertEqual(sut.eMailErrorLabel.text, errorMsg)
    }
    
    func testShowInfoText() {
        let infoMsg = "Info Msg"
        let sut = prepareSut()
        sut.showInfoText(message: infoMsg)
        XCTAssertEqual(infoMsg, sut.infoTextLabel.text)
    }
    
    func testhideInfoText() {
        let sut = prepareSut()
        sut.hideInfoText()
        XCTAssertEqual(sut.infoTextHeightConstraint.constant, 0.0)
    }
    
    func testShowPasswordSelected() {
        let sut = prepareSut()
        sut.showPasswordSelected(true)
        XCTAssertFalse(sut.pwdTextField.isSecureTextEntry)
        XCTAssertEqual(sut.pwdShowPasswordBtn.imageView?.image!.pngData(), UIImage(named: "icon_showpass_selected")?.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!)?.pngData())
    }
    
    func testShowPasswordDeSelected() {
        let sut = prepareSut()
        sut.showPasswordSelected(false)
        XCTAssertTrue(sut.pwdTextField.isSecureTextEntry)
        XCTAssertEqual(sut.pwdShowPasswordBtn.imageView?.image!.pngData(),
                       UIImage(named: "icon_showpass_unselected")?.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!)?.pngData())
    }
    
    func testShowRememberLoginSelected() {
        let sut = prepareSut()
        sut.showRememberLoginSelected(true)
        XCTAssertEqual(sut.rememberLoginBtn.imageView?.image?.pngData(),
                       UIImage(named: "checkbox_selected")?.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!)?.pngData())
    }
    
    func testShowRememberLoginDeSelected() {
        let sut = prepareSut()
        sut.showRememberLoginSelected(false)
        XCTAssertEqual(sut.rememberLoginBtn.imageView?.image!.pngData(), UIImage(named: "checkbox_unselected")?.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!)?.pngData())
    }
    
    func testSetLoginButtonState() {
        let sut = prepareSut()
        sut.setLoginButtonState(.progress)
        XCTAssertEqual(sut.loginBtn.btnState, .progress)
    }
    
    func testLoginButtonState() {
        let sut = prepareSut()
        sut.setLoginButtonState(.progress)
        let btnState = sut.loginButtonState()
        XCTAssertEqual(btnState, .progress)
    }
    
    func testRefreshTopPlaceholderLabelWithEmptyValues() {
        let sut = prepareSut()
        sut.pwdTextField.text = ""
        sut.eMailTextField.text = ""
        sut.refreshTopPlaceholderLabel()
        XCTAssertTrue(sut.pwdTopLabel.isHidden)
        XCTAssertTrue(sut.eMailTopLabel.isHidden)
    }
    
    func testRefreshTopPlaceholderLabelWithValues() {
        let sut = prepareSut()
        sut.eMailTextField.text = "test@gamil.com"
        sut.pwdTextField.text = "test@123"
        sut.refreshTopPlaceholderLabel()
        XCTAssertFalse(sut.pwdTopLabel.isHidden)
        XCTAssertFalse(sut.eMailTopLabel.isHidden)
    }
    
    func testShowPWDError() {
        let sut = prepareSut()
        sut.showPWDError(message: "Mock Error")
        XCTAssertFalse(sut.pwdErrorLabel.isHidden)
        XCTAssertEqual(sut.pwdErrorLabel.text, "Mock Error")
    }
    
    func testEMailFieldContent() {
        let sut = prepareSut()
        sut.eMailTextField.text = "test@gamil.com"
        XCTAssertEqual(sut.eMailFieldContent(), "test@gamil.com")
    }
    
    func testpwdFieldContent() {
        let sut = prepareSut()
        sut.pwdTextField.text = "test@123"
        XCTAssertEqual(sut.pwdFieldContent(), "test@123")
    }
}

class SCLoginPresenterMock: SCLoginPresenting {
    private(set) var isViewDidLoadCalled: Bool = false
    private(set) var isViewWillAppearCalled: Bool = false
    private(set) var isRegisterWasPressed: Bool = false
    private(set) var isRecoverPwdWasPressed: Bool = false
    private(set) var isCancelBtnWasPressed: Bool = false
    var isLoginRememberedCalled: Bool = false
    private(set) var rememberLoginCalled: Bool = false
    private(set) var isShowPwdCalled: Bool = false

    private(set) var isHelpFAQWasPressed: Bool = false
    private(set) var isImprintButtonWasPressed: Bool = false
    private(set) var isSecurityButtonWasPressed: Bool = false
    private(set) var isDataPrivacySettingsButtonWasPressed: Bool = false
    private(set) var isAccessibilityStatementButtonWasPressed: Bool = false
    private(set) var isFeedbackWasPressed: Bool = false
    private(set) var isSoftwareLicensekWasPressed: Bool = false
    private(set) var isLoginWasPressed: Bool = false
    
    func viewDidLoad() {
        isViewDidLoadCalled = true
    }
    
    func viewWillAppear() {
        isViewWillAppearCalled = true
    }
    
    func setDisplay(_ display: OSCA.SCLoginDisplaying) {
    }
    
    func registerWasPressed() {
        isRegisterWasPressed = true
    }
    
    func recoverPwdWasPressed() {
        isRecoverPwdWasPressed = true
    }
    
    func rememberLoginWasPressed() {
        rememberLoginCalled = true
    }
    
    func pwdShowPasswordWasPressed() {
        isShowPwdCalled = true
    }
    
    func loginWasPressed() {
        isLoginWasPressed = true
    }
    
    func cancelWasPressed() {
        isCancelBtnWasPressed = true
    }
    
    func helpFAQWasPressed() {
        isHelpFAQWasPressed = true
    }
    
    func imprintButtonWasPressed() {
        isImprintButtonWasPressed = true
    }
    
    func securityButtonWasPressed() {
        isSecurityButtonWasPressed = true
    }
    
    func dataPrivacySettingsButtonWasPressed() {
        isDataPrivacySettingsButtonWasPressed = true
    }
    
    func accessibilityStatementButtonWasPressed() {
        isAccessibilityStatementButtonWasPressed = true
    }
    
    func feedbackWasPressed() {
        isFeedbackWasPressed = true
    }
    
    func softwareLicensekWasPressed() {
        isSoftwareLicensekWasPressed = true
    }
    
    func eMailFieldDidBeginEditing() {
        
    }
    
    func eMailFieldDidChange() {
        
    }
    
    func passwordFieldDidBeginEditing() {
        
    }
    
    func passwordFieldDidChange() {
        
    }
    
    func isLoginRemembered() -> Bool {
        return isLoginRememberedCalled
    }
    
    var completionOnSuccess: (() -> Void)?
    
    var completionOnCancel: (() -> Void)?
    
    var dismissAfterSuccess: Bool = false
    
    
}
