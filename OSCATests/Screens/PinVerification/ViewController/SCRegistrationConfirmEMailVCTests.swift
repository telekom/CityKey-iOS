//
//  SCRegistrationConfirmEMailVCTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 16/07/24.
//  Copyright © 2024 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

final class SCRegistrationConfirmEMailVCTests: XCTestCase {
    
    private func prepareSur(presenter: SCRegistrationConfirmEMailPresenting? = nil) -> SCRegistrationConfirmEMailVC {
        let storyboard = UIStoryboard(name: "RegistrationScreen", bundle: nil)
        let sut = storyboard.instantiateViewController(identifier: "SCRegistrationConfirmEMailViewController") as! SCRegistrationConfirmEMailVC
        sut.presenter = presenter ?? SCRegistrationConfirmEMailPresenterMock()
        sut.loadViewIfNeeded()
        return sut
    }
    
    func testViewDidLoad() {
        let sut = prepareSur()
        sut.viewDidLoad()
        guard let presenter = sut.presenter as? SCRegistrationConfirmEMailPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isViewDidLoadCalled)
        XCTAssertEqual(sut.resentLabel.text, "r_004_registration_confirmation_info_not_received".localized())
        XCTAssertEqual(sut.resentBtn.titleLabel?.text, " " + "r_004_registration_confirmation_btn_resend".localized())
        XCTAssertEqual(sut.resentBtn.currentImage?.pngData(),
                       UIImage(named: "action_resend_email")?.maskWithColor(color: UIColor(named: "CLR_OSCA_BLUE")!)?.pngData())
        XCTAssertEqual(sut.confirmBtn.titleLabel?.text, "r_004_registration_confirmation_confirm_btn".localized())
        XCTAssertTrue(sut.confirmBtn.isHidden)
        XCTAssertTrue(sut.notificationView.isHidden)
        XCTAssertEqual(sut.pinTextField.keyboardType, .asciiCapableNumberPad)
    }
    
    func testResentBtnWasPressed() {
        let sut = prepareSur()
        sut.resentBtnWasPressed(UIButton())
        guard let presenter = sut.presenter as? SCRegistrationConfirmEMailPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isResendCalled)
    }
    
    func testConfirmBtnWasPressed() {
        let sut = prepareSur()
        sut.confirmBtnWasPressed(UIButton())
        guard let presenter = sut.presenter as? SCRegistrationConfirmEMailPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isConfirmCalled)
    }
    
    func testcancelBtnWasPressed() {
        let sut = prepareSur()
        sut.cancelBtnWasPressed(UIButton())
        guard let presenter = sut.presenter as? SCRegistrationConfirmEMailPresenterMock else {
            XCTFail("Test Failed")
            return
        }
        XCTAssertTrue(presenter.isCancelCalled)
    }
    
    func testPinTextFieldDidChange() {
        let sut = prepareSur()
        sut.pinTextFieldDidChange(UIButton())
        XCTAssertEqual(sut.errorLabel.text, "")
        XCTAssertEqual(sut.validationState, .unmarked)
        XCTAssertEqual(sut.resentLabelTopSpaceStackView.constant, 60)
    }
    
    func testSetupUIWithTitleText() {
        let sut = prepareSur()
        let mockAttributedString = NSMutableAttributedString(string: "r_004_registration_confirmation_info_sent_mail".localized())
        _ = mockAttributedString.setAsBoldFont(textToFind: sut.registeredEmail,
                                           fontSize: sut.titleLabel.font.pointSize)
        sut.setupUIWithTitleText(titleText: "f_001_forgot_password_btn_reset_password".localized(),
                                 topText: "r_004_registration_confirmation_info_sent_mail".localized(),
                                 detailText: "f_002_forgot_pwd_confirmation_info_enter_pin".localized(),
                                 topImageSymbol: UIImage(named: "icon_reset_password")!)
        XCTAssertEqual(sut.titleLabel.attributedText, mockAttributedString)
        XCTAssertEqual(sut.detailLabel.text, "f_002_forgot_pwd_confirmation_info_enter_pin".localized())
        XCTAssertEqual(sut.navigationItem.title, "f_001_forgot_password_btn_reset_password".localized())
    }
    
    func testHideConfirmButton() {
        let sut = prepareSur()
        sut.hideConfirmButton()
        XCTAssertEqual(sut.confirmButtonHeightConstraint.constant, 0.0)
        XCTAssertTrue(sut.confirmBtn.isHidden)
    }

    func testHideTopImage() {
        let sut = prepareSur()
        sut.hideTopImage()
        XCTAssertEqual(sut.topImageHeightConstraint.constant, 0.0)
        XCTAssertTrue(sut.topImageView.isHidden)
        XCTAssertTrue(sut.topImageSymbolView.isHidden)
    }
    
    func testDisableResendButton() {
        let sut = prepareSur()
        sut.disableResendButton(disable: false)
        XCTAssertEqual(sut.resentBtn.currentImage?.pngData(),
                       UIImage(named: "action_resend_email")?.maskWithColor(color: UIColor(named: "CLR_BUTTON_GREY_DISABLED")!)?.pngData())
    }
    
    func testDisplayResendFinished() {
        let sut = prepareSur()
        sut.displayResendFinished(message: "message", textColor: UIColor.green)
        XCTAssertEqual(sut.notificationLabel.text, "message")
        XCTAssertEqual(sut.notificationLabel.textColor, UIColor.green)
        XCTAssertFalse(sut.notificationView.isHidden)
        XCTAssertTrue(sut.titleTopConstraint.isActive == false)
    }
    
    func testDisplayPinError() {
        let sut = prepareSur()
        sut.displayPinError(message: "Error")
        XCTAssertEqual(sut.errorLabel.text, "Error")
        XCTAssertEqual(sut.validationState, .wrong)
    }
    
    func testHidePinError() {
        let sut = prepareSur()
        sut.hidePinError()
        XCTAssertEqual(sut.errorLabel.text, "")
        XCTAssertEqual(sut.validationState, .unmarked)
    }
    
    func testClearPinField() {
        let sut = prepareSur()
        sut.clearPinField()
        XCTAssertEqual(sut.pinTextField.text, "")
    }
    
    func testEnteredPin() {
        let mockPin = "223344"
        let sut = prepareSur()
        sut.pinTextField.text = mockPin
        XCTAssertEqual(sut.enteredPin(), mockPin)
    }
    
    func testDisableConfirmBtn() {
        let sut = prepareSur()
        sut.disableConfirmBtn(disable: true)
        XCTAssertEqual(sut.confirmBtn.btnState, .disabled)
    }
}

final class SCRegistrationConfirmEMailPresenterMock: SCRegistrationConfirmEMailPresenting {
    
    private(set) var isViewDidLoadCalled: Bool = false
    private(set) var isResendCalled: Bool = false
    private(set) var isConfirmCalled: Bool = false
    private(set) var isCancelCalled: Bool = false
    
    func viewDidLoad() {
        isViewDidLoadCalled = true
    }
    
    func setDisplay(_ display: OSCA.SCRegistrationConfirmEMailDisplaying) {
        
    }
    
    func resendWasPressed() {
        isResendCalled = true
    }
    
    func confirmWasPressed() {
        isConfirmCalled = true
    }
    
    func cancelWasPressed() {
        isCancelCalled = true
    }
}
