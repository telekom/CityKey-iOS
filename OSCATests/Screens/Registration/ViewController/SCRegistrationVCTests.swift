//
//  SCRegistrationVCTests.swift
//  OSCATests
//
//  Created by Bhaskar N S on 03/07/24.
//  Copyright © 2024 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import XCTest
@testable import OSCA

final class SCRegistrationVCTests: XCTestCase {
    
    private func prepareSut(presenter: SCRegistrationPresenting? = nil) -> SCRegistrationVC {
        let storyboard = UIStoryboard(name: "RegistrationScreen", bundle: nil)
        let sut = storyboard.instantiateViewController(identifier: "SCRegistrationVC") as! SCRegistrationVC
        sut.presenter = presenter ?? SCRegistrationPresenterMock()
        sut.loadViewIfNeeded()
        return sut
    }
    
    func testViewDidLoad() {
        let sut = prepareSut()
        sut.viewDidLoad()
        guard let presenter = sut.presenter as? SCRegistrationPresenterMock else {
            XCTFail("Test failed")
            return
        }
        XCTAssertTrue(presenter.isViewLoaded)
    }

    func testPrivacyViewWasPressed() {
        let sut = prepareSut()
        sut.privacyViewWasPressed()
        guard let presenter = sut.presenter as? SCRegistrationPresenterMock else {
            XCTFail("Test failed")
            return
        }
        XCTAssertTrue(presenter.isPrivacyViewWasCalled)
    }
    
    func testSubmitBtnWasPressed() {
        let sut = prepareSut()
        sut.submitBtnWasPressed(UIButton())
        guard let presenter = sut.presenter as? SCRegistrationPresenterMock else {
            XCTFail("Test failed")
            return
        }
        XCTAssertTrue(presenter.isSubmitWasCalled)
    }
    
    func testPrivacyBtnWasPressed() {
        let sut = prepareSut()
        sut.privacyBtnWasPressed(UIButton())
        guard let presenter = sut.presenter as? SCRegistrationPresenterMock else {
            XCTFail("Test failed")
            return
        }
        XCTAssertTrue(presenter.isPrivacyViewWasCalled)
    }
    
    func testCloseBtnWasPressed() {
        let sut = prepareSut()
        sut.closeBtnWasPressed(UIButton())
        guard let presenter = sut.presenter as? SCRegistrationPresenterMock else {
            XCTFail("Test failed")
            return
        }
        XCTAssertTrue(presenter.isCloseWasPressed)
    }
    
    func testPrivacyAccepted() {
        let sut = prepareSut()
        sut.updatePrivacyValidationState(true, 
                                         showErrorInfoWhenNotAccepted: false)
        XCTAssertEqual(sut.privacyValidationStateView.image?.pngData(), UIImage(named: "icon_val_ok")?.pngData())
    }
    
    func testPrivacyNotAccepted() {
        let sut = prepareSut()
        sut.updatePrivacyValidationState(false,
                                         showErrorInfoWhenNotAccepted: true)
        XCTAssertEqual(sut.privacyValidationStateLabel.text, "r_001_registration_label_consent_required".localized())
        XCTAssertEqual(sut.privacyValidationStateView.image?.pngData(), UIImage(named: "icon_val_error")?.pngData())
    }
    
    func testPrivacyCheckboxTrue() {
        let sut = prepareSut()
        sut.updatePrivacyCheckbox(accepted: true)
        XCTAssertEqual(sut.privacyBtn.currentImage?.pngData(), UIImage(named: "checkbox_selected")?.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!)?.pngData())
    }
    
    func testPrivacyCheckboxFalse() {
        let sut = prepareSut()
        sut.updatePrivacyCheckbox(accepted: false)
        XCTAssertEqual(sut.privacyBtn.currentImage?.pngData(), UIImage(named: "checkbox_unselected")?.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!)?.pngData())
    }
    
    func testSetupNavigationBar() {
        let navTitle = "Title"
        let backBtnTitle = ""
        let sut = prepareSut()
        sut.setupNavigationBar(title: navTitle, backTitle: backBtnTitle)
        XCTAssertEqual(sut.navigationItem.title, navTitle)
    }
    
    func testSetupUI() {
        let title = "Title"
        let sut = prepareSut()
        sut.setupUI(title: title)
        XCTAssertEqual(sut.submitBtn.titleLabel?.text, title)
        XCTAssertNil(sut.privacyValidationStateView.image)
        XCTAssertEqual(sut.submitBtn.titleLabel?.text, title)
        XCTAssertEqual(sut.privacyValidationStateLabel.text, "")
        XCTAssertEqual(sut.privacyBtn.currentImage?.pngData(),
                       UIImage(named: "checkbox_unselected")?.maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK")!)?.pngData())
    }
    
    func testSetDisallowedCharacterForPassword() {
        let disAllowedChars = "disAllowedChars"
        let sut = prepareSut()
        sut.setDisallowedCharacterForPassword(disAllowedChars)
        XCTAssertEqual(sut.txtfldPwd1?.disallowedCharacters, disAllowedChars)
        XCTAssertEqual(sut.txtfldPwd2?.disallowedCharacters, disAllowedChars)
    }
    
    func testSetDisallowedCharacterForEMail() {
        let disAllowedChars = "disAllowedChars"
        let sut = prepareSut()
        sut.setDisallowedCharacterForEMail(disAllowedChars)
        XCTAssertEqual(sut.txtfldEmail?.disallowedCharacters, disAllowedChars)
    }
    
    func testSetSubmitButtonState() {
        let mockBtnState = SCCustomButtonState.progress
        let sut = prepareSut()
        sut.setSubmitButtonState(mockBtnState)
        XCTAssertEqual(sut.submitBtn.btnState, mockBtnState)
    }
    
    func testGetValue() {
        let mockEmail = "test@gmail.com"
        let sut = prepareSut()
        sut.txtfldEmail?.text = mockEmail
        let value = sut.getValue(for: .email)
        XCTAssertEqual(value, mockEmail)
        
        let mockPwd1 = "test@123"
        sut.txtfldPwd1?.text = mockPwd1
        let pwd1 = sut.getValue(for: .pwd1)
        XCTAssertEqual(pwd1, mockPwd1)
        
        let mockPwd2 = "test@123"
        sut.txtfldPwd2?.text = mockPwd2
        let pwd2 = sut.getValue(for: .pwd2)
        XCTAssertEqual(pwd2, mockPwd2)
        
        let mockDOB = "10/11/1991"
        sut.txtfldBirthdate?.text = mockDOB
        let dob = sut.getValue(for: .birthdate)
        XCTAssertEqual(dob, mockDOB)
        
        let mockPostalCode = "11111"
        sut.txtfldPostalCode?.text = mockPostalCode
        let postalCode = sut.getValue(for: .postalCode)
        XCTAssertEqual(postalCode, mockPostalCode)

    }
    
    func testHideError() {
        let sut = prepareSut()
        sut.hideError(for: .email)
        XCTAssertTrue(sut.txtfldEmail?.errorLabel.isHidden ?? false)
        XCTAssertEqual(sut.txtfldEmail?.validationState, SCTextfieldValidationState.unmarked)
    }
    
    func testSetEnable() {
        let sut = prepareSut()
        sut.setEnable(for: .email, enabled: true)
        XCTAssertTrue(sut.txtfldEmail?.isEnabled() ?? false)
    }
    
    func testShowError() {
        let sut = prepareSut()
        sut.showError(for: .email, text: "invalid email")
        XCTAssertFalse(sut.txtfldEmail?.errorLabel.isHidden ?? true)
        XCTAssertEqual(sut.txtfldEmail?.errorLabel.text, "invalid email")
        XCTAssertEqual(sut.txtfldEmail?.validationState, .wrong)
    }
    
    func testShowMessagse() {
        let sut = prepareSut()
        sut.showMessagse(for: .email, text: "message", color: .green)
        XCTAssertFalse(sut.txtfldEmail?.errorLabel.isHidden ?? true)
        XCTAssertEqual(sut.txtfldEmail?.errorLabel.text, "message")
    }
    
    func testDeleteContent() {
        let sut = prepareSut()
        sut.deleteContent(for: .email)
        XCTAssertEqual(sut.txtfldEmail?.text, "")
    }
    
    func testUpdateValidationStateWithEmail() {
        let sut = prepareSut()
        sut.updateValidationState(for: .email, state: .ok)
        XCTAssertEqual(sut.txtfldEmail?.validationState, .ok)
    }
    
    func testUpdateValidationStateWithPwd() {
        let sut = prepareSut()
        sut.updateValidationState(for: .pwd1, state: .ok)
        XCTAssertEqual(sut.txtfldPwd1?.validationState, .ok)
    }
    
    func testLinkWasTapped() {
        let sut = prepareSut()
        sut.linkWasTapped(label: sut.privacyLabel)
        guard let presenter = sut.presenter as? SCRegistrationPresenterMock else {
            XCTFail("Test failed")
            return
        }
        XCTAssertTrue(presenter.isDataPrivacyLinkWasPressed)
    }
    
    func testBaseTextWasTapped() {
        let sut = prepareSut()
        sut.baseTextWasTapped(label: sut.privacyLabel)
        guard let presenter = sut.presenter as? SCRegistrationPresenterMock else {
            XCTFail("Test failed")
            return
        }
        XCTAssertTrue(presenter.isPrivacyViewWasCalled)
    }
    
    func testTextFieldComponentDidChange() {
        let sut = prepareSut()
        sut.textFieldComponentDidChange(component: sut.txtfldEmail!)
        guard let presenter = sut.presenter as? SCRegistrationPresenterMock else {
            XCTFail("Test failed")
            return
        }
        XCTAssertNotNil(presenter.inputField)
    }
    
    func textFieldComponentEditingEnd() {
        let sut = prepareSut()
        sut.textFieldComponentEditingEnd(component: sut.txtfldEmail!)
        guard let presenter = sut.presenter as? SCRegistrationPresenterMock else {
            XCTFail("Test failed")
            return
        }
        XCTAssertNotNil(presenter.didEndEditingCalled)
    }
    
    func testGetValidationState() {
        let sut = prepareSut()
        sut.txtfldEmail?.text = "test@gmail.com"
        let state = sut.getValidationState(for: .email)
        XCTAssertEqual(state, .unmarked)
    }
}


class SCRegistrationPresenterMock: SCRegistrationPresenting {
    private(set) var isViewLoaded: Bool = false
    private(set) var isViewAppeared: Bool = false
    private(set) var isViewWillAppeared: Bool = false
    private(set) var isPrivacyViewWasCalled: Bool = false
    private(set) var isSubmitWasCalled: Bool = false
    private(set) var isCloseWasPressed: Bool = false
    private(set) var isDataPrivacyLinkWasPressed: Bool = false
    private(set) var inputField: SCRegistrationInputFields?
    private(set) var didEndEditingCalled: Bool = false
    private(set) var isDobTapped: Bool = false
    
    func setDisplay(_ display: OSCA.SCRegistrationDisplaying) {
        
    }
    
    func configureField(_ field: OSCA.SCTextFieldConfigurable?, identifier: String?, type: OSCA.SCRegistrationInputFields, autocapitalizationType: UITextAutocapitalizationType) -> OSCA.SCTextFieldConfigurable? {
        guard let textfield = field else {
            return nil
        }
        switch type {
        case .email:
            textfield.configure(placeholder: "Email", fieldType: .email, maxCharCount: 255, autocapitalization: .none)
            return field
        case .pwd1:
            textfield.configure(placeholder: "password", fieldType: .password, maxCharCount: 255, autocapitalization: .none)
            return textfield
        case .pwd2:
            textfield.configure(placeholder: "confirm password", fieldType: .password, maxCharCount: 255, autocapitalization: .none)
            return textfield
        case .birthdate:
            textfield.configure(placeholder: "Date Of Birth", fieldType: .birthdate, maxCharCount: 255, autocapitalization: .none)
            return textfield
        case .postalCode:
            textfield.configure(placeholder: "Postalcode", fieldType: .postalCode, maxCharCount: 255, autocapitalization: .none)
            return textfield
        }
    }
    
    func textFieldComponentDidChange(for inputField: OSCA.SCRegistrationInputFields) {
        self.inputField = inputField
    }
    
    func txtFieldEditingDidEnd(value: String, inputField: OSCA.SCRegistrationInputFields, textFieldType: OSCA.SCTextfieldComponentType) {
        didEndEditingCalled = true
    }
    
    func submitWasPressed() {
        isSubmitWasCalled = true
    }
    
    func privacyWasPressed() {
        isPrivacyViewWasCalled = true
    }
    
    func closeWasPressed() {
        isCloseWasPressed = true
    }
    
    func dataPrivacyLinkWasPressed() {
        isDataPrivacyLinkWasPressed = true
    }
    
    func viewDidLoad() {
        isViewLoaded = true
    }
    
    func textFieldDateOfBirthTapped() {
        isDobTapped = true
    }
}
